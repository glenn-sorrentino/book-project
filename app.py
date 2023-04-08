from flask import Flask, render_template, request, redirect
import os
import requests
from bs4 import BeautifulSoup
import subprocess

app = Flask(__name__)

def kill_process_on_port(port):
    command = f"lsof -t -i :{port}"
    process_ids = subprocess.check_output(command, shell=True).decode().strip().split('\n')
    for process_id in process_ids:
        if process_id:
            os.system(f"kill {process_id}")

# Kill any process running on port 8080
kill_process_on_port(8080)

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

    # Create the 'chapters' directory inside the 'book_directory'
    chapters_directory = os.path.join(book_directory, 'chapters')
    os.makedirs(chapters_directory, exist_ok=True)

    # Extract the cover, table of contents, and chapters
    cover = soup.find('body')
    toc = soup.find('div', {'id': 'toc'})
    chapters = soup.find_all('div', {'class': 'chapter'})

    # Save the cover, table of contents, and chapters as HTML files
    with open(os.path.join(book_directory, 'cover.html'), 'w') as f:
        f.write(str(cover))

    with open(os.path.join(chapters_directory, 'toc.html'), 'w') as f:
        f.write(str(toc))

    for i, chapter in enumerate(chapters):
        with open(os.path.join(chapters_directory, f'chapter-{i+1}.html'), 'w') as f:
            f.write(str(chapter))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)

