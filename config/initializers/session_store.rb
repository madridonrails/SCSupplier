# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_scsupplier_session',
  :secret      => '53d4b6cd3a92416c242df7259791e234ce38663051c1a161391ccc168c18924c8e57e12c99528d1b493aa16f37e1a43c684bced245ecbad63d00636fa8418883'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
