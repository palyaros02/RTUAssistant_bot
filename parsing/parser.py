from bs4 import BeautifulSoup
import requests
import lxml
import csv
import json

URL = "https://www.mirea.ru/schedule/"
HOST = "https://www.mirea.ru/"

HEADERS = {
    'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'user-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:86.0) Gecko/20100101 Firefox/86.0'
}

def get_src(url):
    req = requests.get(url)
    src = req.text

    # If parser will be blocked by site
    # with open("parsing/index.html", "w", encoding="utf-8") as file:
    #     file.write(src)
    # with open("parsing/index.html", encoding="utf-8") as file:
    #     src = file.read()

    return src


def get_content(src):
    soup = BeautifulSoup(src, "lxml")
    items = soup.find_all(class_="uk-link-toggle")
    hrefs = []

    for item in items:
        item_href = item.get("href").replace(" ", "%20")
        hrefs.append(item_href)

        
    with open("parsing/hrefs.json", "w", encoding="utf-8") as file:
        json.dump(hrefs, file, indent=0, ensure_ascii=False)
    
    with open("parsing/hrefs.csv", "w", newline='', encoding="utf-8") as file:
        writer = csv.writer(file, delimiter=';')
        for item in hrefs:
            writer.writerow([item])


get_content(get_src(URL))
        