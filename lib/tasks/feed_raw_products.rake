namespace :scsupplier do
  
  desc "feed raw_products"
  task :feed_raw_products => :environment do |t|
    puts "please confirm you want to feed raw_products (type 'yes' to confirm anything else to skip)"
    s_answer = $stdin.gets
    if s_answer.chomp == 'yes'

      p = RawProduct.new
      p.name = "Producto base 1"
      p.description = "Descripción 1"
      p.provider_id = 1
      p.save

      p = RawProduct.new
      p.name = "Producto base 2"
      p.description = "Descripción 2"
      p.provider_id = 2
      p.save
      

    else
      puts 'action skipped'
     end
  end #task do
end #namespace

