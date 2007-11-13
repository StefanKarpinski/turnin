#!/usr/bin/env perl

sub get_addr {
	my ($binary,$flags,$regex) = @_;
	open OBJDUMP, "objdump $flags $binary |" or die $!;
	while (<OBJDUMP>) {
		/^\s*([0-9a-f]+):?\s*$regex/ or next;
		close OBJDUMP; return eval "0x$1";
	}
	die "No address found for $regex in 'objdump $flags $binary'.\n";
}

sub get_addr_interactive {
	my ($binary,$flags,$regex) = @_;
	my $tty = `tty`; chomp $tty;
	open TTY, "+<$tty" or die $!;
	system "objdump $flags $binary | egrep -C8 '$regex' >$tty 2>&1";
prompt: print TTY "Enter the correct address: ";
	my $addr = <TTY>;
	$addr =~ /^\s*(?:0x)?([0-9a-f]+):?(?!\S)/ or
	print TTY "Not a valid address.\n" and goto prompt;
	close TTY; return eval "0x$1";
}

$binary = shift or die "usage: $0 <binary> [offset before target]\n";
$strcpy = get_addr $binary, -d => qr/.*<strcpy\@plt>/;
$compress = get_addr $binary, -t => qr/.*\bcompresscmd\s*$/;
$assignment = get_addr $binary, -t => qr/.*\bassignment\s*$/;
$target = get_addr_interactive $binary, -d => q/.*\bcall\b.*<execl@plt>/;

printf "strcpy     0x%08x\n", $strcpy;
printf "target     0x%08x\n", $target;
printf "compress   0x%08x\n", $compress;
printf "assignment 0x%08x\n", $assignment;
