# PermalinkConstructor

This gem generates permalinks from any model attribute. It can transliterate cyrillic source attribute, or optionally
add numeric suffix to the permalink, if a record with similar permalink already exists. It supports scopes too.
If permalink is added by hands, it is not regenerated, but suffix adding is still possible.

Этот гем из любого аттрибута создаёт параметр для человеко понятного URL'а (далее permalink). Он поддерживает транслитерацию кириллицы,
и может опционально добавлять к созданному permalinlk'у числовой суффикс, в случае, если уже существует запись с таким же permalink'ом.
Так permalink может генерироваться внутри области видимости (англ. scope). Если вы задали permalink вручную, то он заново не генерируется,
однако числовой суффикс к нему сгенерировать всё ещё возможно.

# Installation

Add this line to your application's Gemfile:
(не буду переводить ))

    gem 'permalink_constructor', git: 'https://github.com/shaggyone/permalink_constructor.git

And then execute:

    $ bundle

## Usage
Example of usage
    class Article
      include PermalinkConstructor
      belongs_to :category
      attr_accessible :title, :body, :permalink

      constructs_permalink_from :title,                        # Construct permalink from :title attribute
                                :validate_uniqueness => true,  # Add uniqueness validator, false by default
                                :allowed_chars => "_a-z0-9\-", # Supported characters in regexp format,
                                                               # all unmatched characted will be replaced with - (dash character)
                                                               # default is "_a-z0-9\/\-"
                                                               # (note, that default supports '/' (slash) character.
                                :scope => :category_id,        # scope, different categories can have articles with the same permalink
                                                               # nil by default
                                :increment => true,            # add numeric suffix, to the permalink, if needed, false by default
                                :permalink_field => :permalink # May be omited, as it is :permalink by default
    end

Тот же пример с комментариями по русски.
    class Article
      include PermalinkConstructor
      belongs_to :category
      attr_accessible :title, :body, :permalink

      constructs_permalink_from :title,                        # Генерировать permalink из аттрибута :title
                                :validate_uniqueness => true,  # Добавить проверку уникальности, по умолчанию false
                                :allowed_chars => "_a-z0-9\-", # Поддерживаемые символы, как в regexp.
                                                               # Все остальные символы заменяются символом "-" (минус)
                                                               # дефолтное значение "_a-z0-9\/\-"
                                                               # (обратите внимание, что по умолчанию поддерживается символ "/" (прямой слэш)
                                :scope => :category_id,        # Область видимости, в разных категориях могут быть статьи с одинакомым permalink.
                                                               # по умолчанию nil
                                :increment => true,            # К permalink'у будет добавляться числовой суффикс, по умолчанию false
                                :permalink_field => :permalink # Этот параметр можно опустить, т.к. по умолчанию он :permalink
    end

Testing with rspecs

Add line to spec_helper.rb
    require 'permalink_constructor/testing_support/permalink_matchers'

Inside of your model spec write something similar to:

    # Check validation of uniqueness of the permalink
    it { should validate_uniqueness_of(:permalink) }

    # Check if it transforms one value of the permalink to another.
    it { should filter_field_value(:permalink).from('/any/value/with/slashes/').to('anyvaluewithslashes') }

    # See lib/permalink_constructor/testing_support/permalink_matchers.rb for the details
    it_behaves_like "constructs permalink", :title

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
