namespace :scsupplier do

  desc "initialize db (initial load of master data)"
  task :initialize => :environment do
    puts "please confirm you want to initialize your db contents  (type 'all' to initialize all users, 'admin' to initialize only the admin user or 'locales' to initilize multilanguage. Type anything else to skip)"
    s_answer = $stdin.gets
    if s_answer.chomp == 'admin' || s_answer.chomp == 'all'
      init_admin_user
      if s_answer.chomp == 'all'
        init_sales_user
        init_stock_user
      end
    elsif s_answer.chomp == 'locales'
      init_locales
    else
      puts 'initialization skipped'
     end
  end #task do

  def init_admin_user
    puts 'initializing admin user'
    u = User.find_or_initialize_by_email 'admin@scsupplier.com'
    u.login = 'admin'
    u.is_admin = true
    u.password = 'admin' if u.new_record?
    u.password_confirmation = 'admin' if u.new_record?
    if u.save
      puts 'done'
    else
      puts 'error'
    end
  end  

  def init_sales_user
    puts 'initializing sales user'
    u = User.find_or_initialize_by_email 'sales@scsupplier.com'
    u.login = 'sales'
    u.is_sales = true
    u.password = 'sales' if u.new_record?
    u.password_confirmation = 'sales' if u.new_record?
    if u.save
      puts 'done'
    else
      puts 'error'
    end
  end  
  
  def init_stock_user
    puts 'initializing stock user'
    u = User.find_or_initialize_by_email 'stock@scsupplier.com'
    u.login = 'stock'
    u.is_stock = true
    u.password = 'stock' if u.new_record?
    u.password_confirmation = 'stock' if u.new_record?
    if u.save
      puts 'done'
    else
      puts 'error'
    end
  end  
  
  def init_locales
    l1 = Locale.find_or_initialize_by_code 'en-UK'
    l1.name='English'
    l1.save
    
    l2 = Locale.find_or_initialize_by_code 'es-ES'
    l2.name='Castellano'
    l2.save!
    
    User.find(:all).each do |user|
      user.locale = l2
      user.save
    end
  end  
end