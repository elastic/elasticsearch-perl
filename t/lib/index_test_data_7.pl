# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

use strict;
use warnings;
use lib 't/lib';

local $ENV{ES_CXN};
local $ENV{ES_CXN_POOL};
my $es = do 'es_sync.pl' or die( $@ || $! );

$es->indices->delete( index => 'test', ignore => 404 );
$es->indices->create( index => 'test' );
$es->cluster->health( wait_for_status => 'yellow' );

my $b = $es->bulk_helper(
    index => 'test'
);
my $i = 1;
for ( names() ) {
    $b->index(
        {   id     => $i,
            source => {
                name   => $_,
                count  => $i,
                color  => ( $i % 2 ? 'red' : 'green' ),
                switch => ( $i % 2 ? 1 : 2 )
            }
        }
    );
    $i++;
}
$b->flush;
$es->indices->refresh;

#===================================
sub names {
#===================================
    return (
        'Adaptoid',                     'Alpha Ray',
        'Alysande Stuart',              'Americop',
        'Andrew Chord',                 'Android Man',
        'Ani-Mator',                    'Aqueduct',
        'Archangel',                    'Arena',
        'Auric',                        'Barton, Clint',
        'Behemoth',                     'Bereet',
        'Black Death',                  'Black King',
        'Blaze',                        'Cancer',
        'Charlie-27',                   'Christians, Isaac',
        'Clea',                         'Contemplator',
        'Copperhead',                   'Darkdevil',
        'Deathbird',                    'Diablo',
        'Doctor Arthur Nagan',          'Doctor Droom',
        'Doctor Octopus',               'Epoch',
        'Eternity',                     'Feline',
        'Firestar',                     'Flex',
        'Garokk the Petrified Man',     'Gill, Donald "Donny"',
        'Glitch',                       'Golden Girl',
        'Grandmaster',                  'Grey, Elaine',
        'Halloween Jack',               'Hannibal King',
        'Hero for Hire',                'Hrimhari',
        'Ikonn',                        'Infinity',
        'Jack-in-the-Box',              'Jim Hammond',
        'Joe Cartelli',                 'Juarez, Bonita',
        'Judd, Eugene',                 'Korrek',
        'Krang',                        'Kukulcan',
        'Lizard',                       'Machinesmith',
        'Master Man',                   'Match',
        'Maur-Konn',                    'Mekano',
        'Miguel Espinosa',              'Mister Sinister',
        'Mogul of the Mystic Mountain', 'Mutant Master',
        'Night Thrasher',               'Nital, Taj',
        'Obituary',                     'Ogre',
        'Owl',                          'Ozone',
        'Paris',                        'Phastos',
        'Piper',                        'Prodigy',
        'Quagmire',                     'Quasar',
        'Radioactive Man',              'Rankin, Calvin',
        'Scarlet Scarab',               'Scarlet Witch',
        'Seth',                         'Slug',
        'Sluggo',                       'Smallwood, Marrina',
        'Smith, Tabitha',               'St. Croix, Claudette',
        'Stacy X',                      'Stallior',
        'Star-Dancer',                  'Stitch',
        'Storm, Susan',                 'Summers, Gabriel',
        'Thane Ector',                  'Toad-In-Waiting',
        'Ultron',                       'Urich, Phil',
        'Vibro',                        'Victorius',
        'Wolfsbane',                    'Yandroth'
    );
}
