package disconnectCount;

use encoding "utf8";
use strict;
use Log qw(message error);
use Utils;
use Misc qw(relog quit);
use Time::HiRes qw(time);

my $dc_count = 0;
my $dcInSequence = 1;
my $dcInSequence_time = time;


Plugins::register("disconnectCount", "disconnect count", \&unload);


my $hooks  = Plugins::addHooks(
   ['disconnected', \&disconnect, undef]

);

my $cmd = Commands::register(
	['dc','disconnect infos',\&dcInfo],
);


sub unload {
   Plugins::delHooks($hooks);
   Commands::unregister($cmd);
   undef $hooks;
   undef $cmd;
}

sub dcInfo {
	my (undef, $args) = @_;
	
	if ($args eq 'count') {
		error("[plugin:disconnectCount] Você foi desconectado ".$dc_count." e " .$dcInSequence." vez(es).\n","info");
	}
}



sub disconnect { 
 my ($self, $args) = @_;
	$dc_count++;
	if ($self eq "disconnected" && $dcInSequence >= 5 && !timeOut($dcInSequence_time, 600)) {
		error "relog por ". $dcInSequence_time;
		quit();
	} elsif ($self eq "disconnected" && !timeOut($dcInSequence_time, 600)) {
		$dcInSequence++;
	} elsif ($self eq "disconnected" && timeOut($dcInSequence_time, 600)) {
		$dcInSequence_time = time;
		$dcInSequence = 1;
	}
}


1;
