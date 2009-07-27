class LocalesController < ApplicationController
  before_filter :login_required

  def index
    @locales = Locale.paginate(
      :page => params[:page],
      :per_page => 10
    )
  end

  def new
    @locale = Locale.new
  end

  def create
    @locale = Locale.new(params[:locale])
    successful = @locale.save rescue false
    if successful
      redirect_to locales_path
    else
      render :action => :new
    end
  end

  def edit
    @locale = Locale.find(params[:id])
  end

  def update
    @locale = Locale.find(params[:id])
    @locale.update_attributes(params[:locale])

    if @locale.save
      redirect_to locales_url
    else
      render :action => :edit
    end
  end

  def destroy
    @locale = Locale.find(params[:id])
    if @locale.destroy
      redirect_to locales_url
    end

  end

  def show
    @locale = Locale.find(params[:id])
  end

  def view_sections
    @locale = Locale.find(params[:id])
    @sections = @locale.sections
  end
  
  def update_key    
    @locale = Locale.find(params[:id])
    value = params[:value]
    @section = params[:section]
    @key = params[:key]
    default_value = @locale.get_default_value_for_section_and_key(@section, @key)
    
    #validacion de variables
    if !((default_value.scan(/\{\w+\}/).uniq - value.scan(/\{\w+\}/).uniq ).empty? && (value.scan(/\{\w+\}/).uniq - default_value.scan(/\{\w+\}/).uniq ).empty? )
      @error = "No hay las mismas variables que en el texto original: #{default_value.scan(/\{\w+\}/).join(',')}"
    end

    if @error.blank?
      gibberish_label_update(@locale.code, "#{@section}__#{@key}", value)
      render :text => '<img src="/images/icon-ok.gif"/>'
    else      
      render :text => '<img src="/images/icon-error.gif"/>'
    end
  end
  
  def translate_model_attribute
    old_locale = Locale.global
    begin
      my_model = params[:model_name].constantize
      my_model_id = params[:model_id].to_i
      my_model_attribute = params[:model_attribute]
      my_object = my_model.find(my_model_id)
      Locale.global = params[:locale_id].to_i
      temp_attribute = my_object.send(my_model_attribute)
      render :update do |p| 
        p << "$('#{params[:field_id]}').value = '#{temp_attribute}';"
      end
    ensure
      Locale.global = old_locale
    end
  end

  private
  
  def authorized?
    is_admin?
  end

  def access_denied
    if logged_in?
      redirect_to edit_user_url(current_user)
    else
      redirect_to root_url
    end
  end

  def gibberish_label_update(language, section_key, value)
    Gibberish.use_language(language) do
      section,key=Gibberish.get_section_and_key(section_key)
      Gibberish.translations[section][key]=value || ''
      Hash.send(:alias_method,:to_yaml,:sorted_to_yaml)
      section_hash=Hash.new
      section_hash[section]=Gibberish.translations[section]

      File.open(File.join(RAILS_ROOT, 'lang', Gibberish.current_language.to_s, "#{section}.yml"),'w') do |f|
        f.puts section_hash.to_yaml
      end
      FileUtils.mkdir_p File.join(RAILS_ROOT,'tmp',"#{Gibberish.current_language}")
      File.open(File.join(RAILS_ROOT, 'tmp', "#{Gibberish.current_language}", "#{section}.yml"),'w') do |f|
        f.puts section_hash.to_yaml
      end           
      
      Hash.send(:alias_method,:to_yaml,:orig_to_yaml)    
    end #use_language
  end  
end
