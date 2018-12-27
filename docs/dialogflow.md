# NluAdapter::Dialogflow

Adapter for Google Dialogflow

## Setup


## Examples

1. Parse a text and identify intent from an existing Lex bot
```ruby
require 'nlu_adapter'

d = NluAdapter.new(:Dialogflow, {project_id: "test-1-NNNN", session_id: 'SESSION1'})

puts d.parse('I want to book a hotel')

```
```
{:intent_name=>"BookHotel"}
```
2. Create an intent
```ruby
require 'nlu_adapter'

d = NluAdapter.new(:Dialogflow, {project_id: "test-1-NNNN", session_id: 'SESSION1'})
i = d.new_intent('BookHotel', ['please book a hotel', 'I want to book a hotel'])

d.create_intent(i)

```

3. Create an intent collection

Create an Agent from Dialogflow console.

## Running examples
```bash
$ cat test-df-1.rb
require 'nlu_adapter'

d = NluAdapter.new(:Dialogflow, {project_id: "test-1-NNNN", session_id: 'SESSION1'})

puts d.parse('I want to book a hotel')

$ GOOGLE_APPLICATION_CREDENTIALS='./test-1-NNNN.json' ruby ./test-df-1.rb
{:intent_name=>"BookHotel"}

```
