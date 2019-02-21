# @markup markdown

# NluAdapter::WatsonAssistant

Adapter for IBM Watson Assistant

## Setup

Please check the [Getting started tutorial](https://cloud.ibm.com/docs/services/assistant/getting-started.html#getting-started)

* To get the API details
 * Go to [resources list](https://cloud.ibm.com/resources)
 * Select the desired service from the Services section
 * Download / Copy the API Key & URL
 * Click on the Launch tool to go to IBM Watson Assistant
 * Select the Skills tab
 * Click on the vertical ... icon for the desired skill
 * Then click on View API Details from the menu
 * Copy the Workspace ID

* To create intents
 * In the above step instead of clicking on the vertical ... icon, click the skill name

## Examples

1. Parse a text and identify intent from an existing skill

```ruby
require 'nlu_adapter'

wa = NluAdapter.new(:WatsonAssistant, {url: 'https://gateway-lon.watsonplatform.net/assistant/api', version: '2018-09-20'})

puts wa.parse('I want to book a hotel')

```
```
{:intent_name=>"BookHotel"}
```
2. Create an intent

```ruby
require 'nlu_adapter'

wa = NluAdapter.new(:WatsonAssistant, {url: 'https://gateway-lon.watsonplatform.net/assistant/api', version: '2018-09-20'})
i = wa.new_intent('BookHotel', ['please book a hotel', 'I want to book a hotel'])

wa.create_intent(i)

```

## Running examples

```bash
$ cat test-wa-1.rb
require 'nlu_adapter'

wa = NluAdapter.new(:WatsonAssistant, {url: 'https://gateway-lon.watsonplatform.net/assistant/api', version: '2018-09-20'})

puts wa.parse('I want to book a hotel')

$ WATSON_API_KEY='XXX' WATSON_WORKSPACE_ID='YYY' ruby ./test-wa-1.rb
{:intent_name=>"BookHotel"}

```
