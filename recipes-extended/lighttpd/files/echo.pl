#!/usr/bin/perl -Tw
$SIG{PIPE} = 'IGNORE';
for (my $FH; accept($FH, STDIN); close $FH) {
    select($FH); $|=1; # $FH->autoflush;
    print $FH $_ while (<$FH>);
}
