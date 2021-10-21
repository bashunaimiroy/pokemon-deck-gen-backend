if ['development', 'test'].include? ENV['RAILS_ENV']
    Dotenv.require_keys('POKEMON_TCG_API_KEY')
end
