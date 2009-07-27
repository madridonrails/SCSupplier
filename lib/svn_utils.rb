module SvnUtils
  mattr_accessor :svn_path
  SvnUtils.svn_path = '/usr/bin'

  mattr_accessor :svn_locale_path
  SvnUtils.svn_locale_path = "#{RAILS_ROOT}/lang"
end
