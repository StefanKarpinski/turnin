#!/usr/bin/env perl
open MAPS, "/proc/$$/maps";
print while <MAPS>;
