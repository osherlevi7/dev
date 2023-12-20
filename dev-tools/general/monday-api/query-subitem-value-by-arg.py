import requests
import json
import argparse

api_key = 'token'
url = 'https://api.monday.com/v2'
headers = {'Authorization': api_key}

def fetch_all_items():
    query = '''
    query {
      boards(ids: [5571017570]) {
        items {
          id
          name
        }
      }
    }
    '''
    response = requests.post(url, json={'query': query}, headers=headers)
    return json.loads(response.text)['data']['boards'][0]['items']

# get subitems of a given item id
def get_subitems(item_id):
    query = '''
    query($itemId: [Int]) {
      items(ids: $itemId) {
        name
        subitems {
          id
          name
          column_values {
            title
            text
          }
        }
      }
    }
    '''
    variables = {'itemId': item_id}
    response = requests.post(url, json={'query': query, 'variables': variables}, headers=headers)
    return json.loads(response.text)

# Main script
def main(item_name):
    items = fetch_all_items()
    
    # Find item by name
    item_id = None
    for item in items:
        if item['name'] == item_name:
            item_id = int(item['id'])
            break
    
    if item_id:
        subitems = get_subitems(item_id)
        print(subitems)
    else:
        print("Item not found.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Fetch subitems from a Monday board item.')
    parser.add_argument('item', help='Name of the item to fetch subitems for')
    # Parse the arguments
    args = parser.parse_args()
    item_name = args.item.split('=')[1] if '=' in args.item else args.item

    main(item_name)