use strict;
use warnings;
use Test::More 'no_plan';
use Test::NoWarnings;

use_ok('Devel::REPL');
use_ok('Devel::REPL::Script');
use_ok('Devel::REPL::Plugin::Colors');
use_ok('Devel::REPL::Plugin::Commands');
use_ok('Devel::REPL::Plugin::DumpHistory');
use_ok('Devel::REPL::Plugin::FancyPrompt');
use_ok('Devel::REPL::Plugin::FindVariable');
use_ok('Devel::REPL::Plugin::History');
use_ok('Devel::REPL::Plugin::Interrupt');
use_ok('Devel::REPL::Plugin::OutputCache');
use_ok('Devel::REPL::Plugin::Packages');
use_ok('Devel::REPL::Plugin::Peek');
use_ok('Devel::REPL::Plugin::ReadLineHistory');
use_ok('Devel::REPL::Plugin::ShowClass');
use_ok('Devel::REPL::Plugin::Timing');
use_ok('Devel::REPL::Plugin::Turtles');
