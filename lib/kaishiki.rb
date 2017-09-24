module Kaishiki
end

Dir[File.join(File.dirname(__FILE__), "kaishiki", "*.rb")].each do |rb_file|
  require rb_file
end
