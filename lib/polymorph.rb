require "polymorph/version"
require "polymorph/methods"
require "active_record"

ActiveRecord::Base.extend(Polymorph::Methods)
