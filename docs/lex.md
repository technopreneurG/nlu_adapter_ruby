# @markup markdown

# NluAdapter::Lex

Adapter for Aws Lex

## Setup

Please check the [documentation](https://aws.amazon.com/lex/).

## Examples

1. Parse a text and identify intent from an existing Lex bot

```ruby
require 'nlu_adapter'

l = NluAdapter.new(:Lex, {bot_name: "BotName", bot_alias: "BotAlias", user_id: "user-1"})

puts l.parse('I want to book a hotel')

```
```
{:intent_name=>"BookHotel"}
```
2. Create an intent

```ruby
require 'nlu_adapter'

l = NluAdapter.new(:Lex, {bot_name: "BotName", bot_alias: "BotAlias", user_id: "user-1"})
i = l.new_intent('BookHotel', ['please book a hotel', 'I want to book a hotel'])

l.create_intent(i)

```

3. Create an intent collection

```ruby

require 'nlu_adapter'

l = NluAdapter.new(:Lex, {bot_name: "BotName", bot_alias: "BotAlias", user_id: "user-1"})
intents = []
i = l.new_intent('BookHotel', ['please book a hotel', 'I want to book a hotel'])
intents << i

ic = l.new_intent_collection('BotName', intents)
l.create_intent_collection(ic)

```

## Running examples

```bash
$ cat test-lex-1.rb
require 'nlu_adapter'

l = NluAdapter.new(:Lex, {bot_name: "BotName", bot_alias: "BotAlias", user_id: "user-1"})

puts l.parse('I want to book a hotel')

$ AWS_REGION='us-east-1' AWS_ACCESS_KEY_ID='XXX' AWS_SECRET_ACCESS_KEY='YYY' ruby ./test-lex-1.rb
{:intent_name=>"BookHotel"}

```
