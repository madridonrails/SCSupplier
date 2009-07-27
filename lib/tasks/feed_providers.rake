namespace :scsupplier do
  
  desc "feed providers"
  task :feed_providers => :environment do |t|
    puts "please confirm you want to feed providers (type 'yes' to confirm anything else to skip)"
    s_answer = $stdin.gets
    if s_answer.chomp == 'yes'

      p = Provider.new
      p.name = "prov 1"
      p.contact = "contacto 1"
      p.save

      p = Provider.new
      p.name = "prov 2"
      p.contact = "contacto 3"
      p.save
      

    else
      puts 'action skipped'
     end
  end #task do
end #namespace

