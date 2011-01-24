# encoding: UTF-8

# All provinces (Bundesländer) of Germany with their name, two-character
# abbreviation, their area in km² and population of the year 2007.
# Data taken from http://de.wikipedia.org/wiki/Land_(Deutschland)
class GermanProvince < ConstantRecord::Base #:nodoc:
  columns :name, :abbr, :area, :population
  data [ 'Baden-Württemberg',      'BW', 35751, 10750000 ],
       [ 'Bayern',                 'BY', 70552, 12520000 ],
       [ 'Berlin',                 'BE',   891,  3416000 ],
       [ 'Brandenburg',            'BB', 29480,  2536000 ],
       [ 'Bremen',                 'HB',   419,   663000 ],
       [ 'Hamburg',                'HH',   755,  1771000 ],
       [ 'Hessen',                 'HE', 21115,  6073000 ],
       [ 'Mecklenburg-Vorpommern', 'MV', 23185,  1680000 ],
       [ 'Niedersachsen',          'NI', 47625,  7972000 ],
       [ 'Nordrhein-Westfalen',    'NW', 34086, 17997000 ],
       [ 'Rheinland-Pfalz',        'RP', 19853,  4046000 ],
       [ 'Saarland',               'SL',  2569,  1037000 ],
       [ 'Sachsen',                'SN', 18418,  4220000 ],
       [ 'Sachsen-Anhalt',         'ST', 20447,  2412000 ],
       [ 'Schleswig-Holstein',     'SH', 15799,  2837000 ],
       [ 'Thüringen',              'TH', 16172,  2289000 ]
end
