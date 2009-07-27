class Locale < ActiveRecord::Base
  has_many :users, :dependent => :nullify

  validates_uniqueness_of :name, :code

  #after_create :create_locale_files
  before_destroy :check_default_locale
  after_destroy :remove_locale_files

  @@global_locale = nil

  def self.global
    begin
      @@global_locale ||= Locale.find_by_code(DEFAULT_LANGUAGE)
    rescue
    end
  end

  def self.global=(locale)
    if locale.is_a? Locale
      @@global_locale = locale
    elsif locale.is_a? String
      locale = Locale.find(:first, :conditions => ['code = ?', locale])
      return false if (! locale)
      @@global_locale = locale
    elsif locale.is_a? Fixnum
      locale = Locale.find(:first, :conditions => ['id = ?', locale])
      return false if (! locale)
      @@global_locale = locale
    else
      # empty
      @@global_locale = nil
    end
  end

  def master?
    self.code == DEFAULT_LANGUAGE
  end

  def self.find_non_master
    self.find(:all, :conditions => ['code <> ?', DEFAULT_LANGUAGE])
  end

  def check_default_locale
    if self.code == DEFAULT_LANGUAGE
      raise('locale__error_default'[])
      return false
    end
  end

  def create_locale_files
    source_dir = File.expand_path(File.join(SvnUtils.svn_locale_path, DEFAULT_LANGUAGE))
    target_dir = File.expand_path(File.join(SvnUtils.svn_locale_path, self.code))

    if !File.directory?(target_dir)
      Dir.mkdir(target_dir)
    
      Dir.chdir(target_dir) do
        FileUtils.cp(Dir.glob("#{source_dir}/*.yml"), target_dir) rescue nil
        system "#{File.join(SvnUtils.svn_path,'svn')} add #{target_dir}"
        system "#{File.join(SvnUtils.svn_path,'svn')} -q -m \"automatically commited from locales manager\" commit #{target_dir}"
      end
    end
  end
  
  def remove_locale_files
    Dir.chdir(SvnUtils.svn_locale_path) do
      FileUtils.rm_rf(self.code)
      system "#{File.join(SvnUtils.svn_path,'svn')} delete #{self.code}"
      system "#{File.join(SvnUtils.svn_path,'svn')} -q -m \"automatically removed from locales manager\" commit"
    end
  end
  
  #------------- begin translations
  def sections
    if !@sections.nil?
      return @sections
    end
    result = Gibberish.all_languages[self.code.to_sym].keys rescue []
    @sections = result.sort_by{|item| item.to_s}
    return @sections
  end

  def keys(section)
    result = Gibberish.all_languages[self.code.to_sym][section.to_sym]
    keys = result.sort_by{|item| item.to_s}
    return keys
  end
  
  def file_name
    return File.join(RAILS_ROOT, 'lang', "#{code}.yml")
  end
  
  def temp_file_name
    return File.join(RAILS_ROOT, 'tmp', "#{code}.yml")
  end

  def get_yaml
    h = Gibberish.all_languages[self.code.to_sym]
    return h
  end
  
  def get_value_for_section_and_key(section, key)
    section = section.to_s
    key = key.to_s
    lst = keys(section)
    lst.each do |v|
      if v[0] == key
        return v[1]
      end
    end
    return nil
  end

  def get_default_value_for_section_and_key(section, key)
    l = Locale.find_by_code(DEFAULT_LANGUAGE)
    lst = l.keys(section)
    lst.each do |v|
      if v[0] == key
        return v[1]
      end
    end
    return nil
  end
  #--- end translations
end
