import requests
import json

api_key = 'token'
url = 'https://api.monday.com/v2'
headers = {'Authorization': api_key}

# Step 1: List all items on the board
query_items = '''
query {
  boards(ids: [5571017570]) {
    groups{
      title
    }
    items {
      id
      name
      
    }
  }
}
'''

response = requests.post(url, json={'query': query_items}, headers=headers)
print(response.text)
items_data = json.loads(response.text)['data']['boards'][0]['items']
