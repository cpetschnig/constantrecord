# All provinces and territories of Canada with their name, two-character
# abbreviation, their capital and population of the year 2010.
# Data taken from http://en.wikipedia.org/wiki/Provinces_and_territories_of_Canada
class CanadianProvince < ConstantRecord::Base #:nodoc:
  columns :name, :abbr, :capital, :population
  data [ 'Alberta',                   'AB', 'Alberta',                    3724832 ],
       [ 'British Columbia',          'BC', 'British Columbia',           4510858 ],
       [ 'Manitoba',                  'MB', 'Manitoba',                   1232654 ],
       [ 'New Brunswick',             'NB', 'New Brunswick',               751273 ],
       [ 'Newfoundland and Labrador', 'NL', 'Newfoundland and Labrador',   510901 ],
       [ 'Nova Scotia',               'NS', 'Nova Scotia',                 940482 ],
       [ 'Ontario',                   'ON', 'Ontario',                   13167894 ],
       [ 'Prince Edward Island',      'PE', 'Charlottetown',               141551 ],
       [ 'Quebec',                    'QC', 'Quebec',                     7886108 ],
       [ 'Saskatchewan',              'SK', 'Saskatchewan',               1041729 ]
end