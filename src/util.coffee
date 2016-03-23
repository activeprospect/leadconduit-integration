humanname = require 'humanname'

# given a string containing a person's full name, return a two-element array containing firstName and lastName
parseFullname = (fullname) ->
  parsed = humanname.parse(fullname)

  salutation: parsed.salutation
  first_name: parsed.firstName
  middle_name: parsed.initials
  last_name: parsed.lastName
  suffix: parsed.suffix


module.exports =
  parseFullname: parseFullname
