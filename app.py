from flask import Flask, render_template, request, redirect
import os
import requests
from bs4 import BeautifulSoup

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/download', methods=['POST'])
def download():
    url = request.form['book_url']
    download_book(url)
    return redirect('/')

def download_book(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    book_title = soup.title.string
    book_directory = os.path.join('book_project', book_title)
    os.makedirs(book_directory, exist_ok=True)
    # Download and save the cover, toc, and chapters here

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
