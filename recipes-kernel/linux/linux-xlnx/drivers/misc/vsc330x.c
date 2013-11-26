 
/*!***************************************************************************
 *! FILE NAME  : vsc330x.c
 *! DESCRIPTION: control of the VSC3304 4x4 crosspoint switch
 *! Copyright (C) 2013 Elphel, Inc.
 *! -----------------------------------------------------------------------------**
 *!
 *!  This program is free software: you can redistribute it and/or modify
 *!  it under the terms of the GNU General Public License as published by
 *!  the Free Software Foundation, either version 3 of the License, or
 *!  (at your option) any later version.
 *!
 *!  This program is distributed in the hope that it will be useful,
 *!  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *!  GNU General Public License for more details.
 *!
 *!  You should have received a copy of the GNU General Public License
 *!  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <linux/i2c.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/mutex.h>
#include <linux/string.h>

#define DRV_VERSION "1.0"
/* TODO: Descriptions from vsc3312 - check differences */
#define I2C_PAGE_CONNECTION        0x00	/* When written to I2C_CURRENT_PAGE, makes registers 0..0xf control corresponding output (0..0xf) source
					   (input number) bit 4 (+0x10) - turn output off, bits 3:0 - source */
#define I2C_PAGE_INPUT_ISE         0x10	/* When written to I2C_CURRENT_PAGE, makes registers 0..0xf control corresponding input (0..0xf)
					   ISE (equalization): Bits 5:4 ISE short: 0 - off, 1 - minimal, 2 - moderate, 3 - maximal;
					   bits 3:2 ISE medium, bits 1:0 ISE Long time constant */
#define I2C_PAGE_INPUT_STATE       0x11	/* When written to I2C_CURRENT_PAGE, makes registers 0..0xf control corresponding input (0..0xf) enable,
					   polarity and termination (default 6)
					   Bit 2 (+4) Terminate to VDD ( 0 - connect,  1 - do not connect) - dedicated (0..7) inputs only
					   Bit 1 (+2) Input power (0 - on, 1 - off)
					   Bit 0 (+1) Invert signal at input  */
#define I2C_INPUT_STATE_DATA       0x04	/* terminated,enabled, not inverted */
#define I2C_PAGE_INPUTLOS          0x12	/* When written to I2C_CURRENT_PAGE, makes registers 0..0xf control corresponding input (0..0xf)
					   LOS (loss of signal) threshold
					   Bits 2:0 - level in mV for dedicated(bidirectional) inputs: 0,1,6,7 - unused, 2 - 150(170),
					   3 - 200(230), 4 - 250(280), 5 - 300(330) */
#define I2C_PAGE_OUTPUT_PRE_LONG   0x20	/* When written to I2C_CURRENT_PAGE, makes registers 0..0xf control corresponding output (0..0xf)
					   long time constant pre-emphasis
					   Bits 6:3 Pre-Emphasis level (0x0 - off, 0x1 - min, 0xf - max - 0..6dB), bits 2:0 - Pre-emphasis
					   decay (0x0 - fastest, 0x7 - slowest) in 500..1500 ps range */
#define I2C_PAGE_OUTPUT_PRE_SHORT  0x21	/* When written to I2C_CURRENT_PAGE, makes registers 0..0xf control corresponding output (0..0xf)
					   short time constant pre-emphasis
					   Bits 6:3 Pre-Emphasis level (0x0 - off, 0x1 - min, 0xf - max - 0..6dB),
					   bits 2:0 - Pre-emphasis decay (0x0 - fastest, 0x7 - slowest) in 30..500 ps range */
#define I2C_PAGE_OUTPUT_LEVEL      0x22	/* When written to I2C_CURRENT_PAGE, makes registers 0..0xf control corresponding output (0..0xf)
					   short time constant pre-emphasis
					   Bits 3:0 - peak-to-peak 0,1,0xe,0xf - unused, 0x2-405mV,0x3-425V,0x4-455mV,0x5-485mV,0x6-520mV,
					   0x7-555mV,0x8-605mV,0x9-655mV,0xa-720mV,0xb-790mV,0xc-890mV,0xd-990mV (+3.3VDC required)
					   bit 4 (+0x10) - for 8-15 used as inputs only: terminate inputs 8..15 to VDDIO-0.7V */
#define I2C_PAGE_OUTPUT_STATE      0x23	/* When written to I2C_CURRENT_PAGE, makes registers 0..0xf control corresponding output (0..0xf)
					   OOB signaling and output polarity
					   bits 4:1 - operation mode: 0xa  - inverted, 0x5 - normal, 0x0 - suppressed
					   bit 0 - OOB control:     1 - enable LOS forwarding, 0 - ignore LOS */
#define I2C_PAGE_CHANNEL_STATUS    0xf0	/* When written to I2C_CURRENT_PAGE, makes registers 0..0xf monitor corresponding input (0..0xf) LOS status
					   bit 0 - LOS status: 1 - LOS detected (loss of signal), 0 - signal present (input has to be enabled,
					   otherwise 0 is read)when reading from address 0x10 of this page:
					   bit 0 - value of STAT0
					   bit 1 - value of STAT1 */
#define I2C_PAGE_STATUS0_CONFIGURE 0x80	/* When written to I2C_CURRENT_PAGE, makes registers 0..0xf control selected input LOS to be OR-ed
					   to STAT0 output pin (and bit)
					   bit 0 : 1 - OR this input channel LOS status to STAT0 */
#define I2C_PAGE_STATUS1_CONFIGURE 0x81	/* When written to I2C_CURRENT_PAGE, makes registers 0..0xf control selected input LOS to be OR-ed
					   to STAT1 output pin (and bit)
					   bit 0 : 1 - OR this input channel LOS status to STAT1 */
#define I2C_GLOBAL_CONNECTION      0x50	/* Bit 4 (+0x10) - disable all outputs, bits 3:0 - input number to connect to all outputs */
#define I2C_GLOBAL_INPUT_ISE       0x51	/* Bits 5:4 ISE short: 0 - off, 1 - minimal, 2 - moderate, 3 - maximal; bits 3:2 ISE medium,
					   bits 1:0 ISE Long time constant */
#define I2C_GLOBAL_INPUT_STATE     0x52	/* Bit 2 (+4) - terminate input to VDD (0..7 only) 0-connect, 1 Normal;
					   Bit 1 (+2) Input power off (0 - On, 1 - Off) bit0 (+1): Input polarity: 1 - inverted, 0 - normal  */
#define I2C_GLOBAL_INPUT_LOS       0x53	/* Bits 2:0 - level in mV for dedicated(bidirectional) inputs: 0,1,6,7 - unused, 2 - 150(170),
					   3 - 200(230), 4 - 250(280), 5 - 300(330) */
#define I2C_GLOBAL_OUTPUT_PRE_LONG 0x54	/* Bits 6:3 Pre-Emphasis level (0x0 - off, 0x1 - min, 0xf - max - 0..6dB),
					   bits 2:0 - Pre-emphasis decay (0x0 - fastest, 0x7 - slowest) in 500..1500 ps range */
#define I2C_GLOBAL_OUTPUT_PRE_SHORT 0x55 /* Bits 6:3 Pre-Emphasis level (0x0 - off, 0x1 - min, 0xf - max - 0..6dB),
					   bits 2:0 - Pre-emphasis decay (0x0 - fastest, 0x7 - slowest) in 30..500 ps range */
#define I2C_GLOBAL_OUTPUT_LEVELl   0x56	/* Bits 3:0 - peak-to-peak 0,1,0xe,0xf - unused,0x2-405mV,0x3-425V,0x4-455mV,0x5-485mV,
					   0x6-520mV,0x7-555mV,0x8-605mV,0x9-655mV,0xa-720mV,0xb-790mV,0xc-890mV,0xd-990mV (+3.3VDC required)
					   bit 4 (+0x10) terminate inputs 8..15 to VDDIO-0.7V */
#define I2C_GLOBAL_OUTPUT_STATE    0x57	/* +1 (bit 0) - LOS, +0x15 - inverted, 0xa0 - normal, +0 - "Common mode" ? */
#define I2C_GLOBAL_OUTPUT_STATE_DATA 0x0b /* No inversion, enable OOB forwarding on all channels */
#define I2C_STATUS0                0x58	/* Bit 0 - selected for Status0 chanel LOS on */
#define I2C_STATUS1                0x59	/* Bit 0 - selected for Status1 chanel LOS on // Which channel LOS to show on Status1 output/bit */
#define I2C_CORE_CONFIGURATION     0x75
#define I2C_CORE_CONFIGURATION_DATA  0x18	/* default 0x18 - 0x10 - leftEn, 0x8 - rightEn, 0x4 - DNU, 0x2 - BufferForceOn, 0x1 - Config polarity */
#define I2C_CORE_CONFIGURATION_DATAF 0x19	/* default with inverted Config polarity (freeze update) */
#if 0
#define I2C_SLAVE_ADDRESS          0x78	/* programmed only, not hardwired */
#endif
#define I2C_INTERFACE_MODE         0x79
#define I2C_INTERFACE_MODE_DATA    0x02	/* i2c (1 - 4-wire)  */
#define I2C_SOFTWARE_RESET         0x7a
#define I2C_SOFTWARE_RESET_DATA    0x10	/* to reset, 0 - normal  */
#define I2C_CURRENT_PAGE           0x7f




static DEFINE_MUTEX(vsc3304_mutex);
static const struct i2c_device_id vsc3304_id[] = {
	{ "vsc3304", 0 },
	{ "vsc3308", 1 },
	{ }
};

MODULE_DEVICE_TABLE(i2c, vsc3304_id);
/*
struct m41t80_data {
	u8 features;
	struct rtc_device *rtc;
};
*/
/* I2C bus functions */
static int write_d8(void *client, u8 val)
{
	return i2c_smbus_write_byte(client, val);
}

static int write_r8d8(void *client, u8 reg, u8 val)
{
	return i2c_smbus_write_byte_data(client, reg, val);
}

static int write_r8d16(void *client, u8 reg, u16 val)
{
	return i2c_smbus_write_word_data(client, reg, val);
}

static int read_d8(void *client)
{
	return i2c_smbus_read_byte(client);
}

static int read_r8d8(void *client, u8 reg)
{
	return i2c_smbus_read_byte_data(client, reg);
}

static int read_r8d16(void *client, u8 reg)
{
	return i2c_smbus_read_word_data(client, reg);
}

static const struct vsc_bus_ops bops = {
	.read_d8	= read_d8,
	.read_r8d8	= read_r8d8,
	.read_r8d16	= read_r8d16,
	.write_d8	= write_d8,
	.write_r8d8	= write_r8d8,
	.write_r8d16	= write_r8d16,
};

static int vsc330x_i2c_probe(struct i2c_client *client,
				      const struct i2c_device_id *id)
{
	struct ad_dpot_bus_data bdata = {
		.client = client,
		.bops = &bops,
	};

	if (!i2c_check_functionality(client->adapter,
				     I2C_FUNC_SMBUS_WORD_DATA)) {
		dev_err(&client->dev, "SMBUS Word Data not Supported\n");
		return -EIO;
	}
	return 1	/* found*/ 
//	return vsc330x_probe(&client->dev, &bdata, id->driver_data, id->name);
}

static int vsc330x_i2c_remove(struct i2c_client *client)
{
	return vsc330x_remove(&client->dev);
}

static struct i2c_driver vsc330x_i2c_driver = {
	.driver = {
		.name	= "vsc330x",
		.owner	= THIS_MODULE,
	},
	.probe		= vsc330x_i2c_probe,
	.remove		= vsc330x_i2c_remove,
	.id_table	= vsc330x_id,
};

module_i2c_driver(vsc330x_i2c_driver);

MODULE_AUTHOR("Andrey Filippov  <andrey@elphel.com>");
MODULE_DESCRIPTION("VSC330x I2C bus driver");
MODULE_LICENSE("GPL");
MODULE_ALIAS("i2c:vsc330x");


