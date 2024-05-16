# Copyright (C) 2024 SUSE LLC
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, see <http://www.gnu.org/licenses/>.

use Mojo::Base -strict;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More;
use Test::Mojo;
use Cavil::Test;
use Mojo::File qw(tempdir);

plan skip_all => 'set TEST_ONLINE to enable this test' unless $ENV{TEST_ONLINE};

my $cavil_test = Cavil::Test->new(online => $ENV{TEST_ONLINE}, schema => 'command_sync_test');
my $config     = $cavil_test->default_config;
my $t          = Test::Mojo->new(Cavil => $config);
my $app        = $t->app;
$cavil_test->mojo_fixtures($app);

my $tempdir = tempdir;
my $dir     = $tempdir->child('license_patterns')->make_path;

subtest 'Sync' => sub {
  subtest 'Export' => sub {
    is $dir->list({dir => 1})->size, 0, 'directory is empty';
    my $buffer = '';
    {
      open my $handle, '>', \$buffer;
      local *STDERR = $handle;
      $app->start('sync', '-e', $dir);
    }
    like $buffer, qr/Exporting 6 patterns/, 'right output';
    isnt $dir->list({dir => 1})->size, 0, 'directories have been created';
  };

  subtest 'Import' => sub {
    my $buffer = '';
    {
      open my $handle, '>', \$buffer;
      local *STDERR = $handle;
      $app->start('sync', '-i', $dir);
    }
    like $buffer, qr/Importing 6 patterns/, 'right output';
  };
};

done_testing();
