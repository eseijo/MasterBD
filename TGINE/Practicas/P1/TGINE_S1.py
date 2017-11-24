# Importamos el wrapper praw para acceder al api de reddit
import praw
# Importamos el parser XML
import xml.etree.ElementTree as ET
# Importamos datetime para tratar fechas
import datetime
# Importamos el CountVectorizer y el TfidfVectorizer
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
# Importamos numpy para realizar operaciones con matrices
import numpy as np
# Importamos sys y getopt para poder obtener los parametros de entrada del script
import sys, getopt

# Definimos los valores necesarios para realizar la conexion al api
CLIENT_ID = 'hYM-vevrJQH5zA'
CLIENT_SECRET = 't5HlntQcK052abHi7CLja-2ep_U'
USERNAME = 'eseijo'
PASSWORD = 'TGINE2017'
USER_AGENT = 'script:redditextractor:0.1 (by /u/eseijo)'

# Subreddit a utilizar
SUBREDDIT = 'personalfinance'
# Tipo de extraccion de contenido
CONTENT_TYPE = 'hot'
# Numero de posts a extraer
N = 100
# Nombre de fichero donde se guardaran los datos extraidos de reddit
FILENAME = 'redditextractor_data.xml'

# Funcion que devuelve los ultimos contenidos de un subreddit
def get_new_content(reddit, subreddit, topN):
    subreddit = reddit.subreddit(subreddit)
    return subreddit.new(limit = topN)

# Funcion que devuelve los contenidos mas populares del momento para un subreddit
def get_hot_content(reddit, subreddit, topN):
    subreddit = reddit.subreddit(subreddit)
    return subreddit.hot(limit = topN)

# Funcion que parsea un comentario a XML y lo anade a una lista
def get_XML_from_reddit_comment(entry, acc = []):
    e = ET.Element('entry')
    title = ET.SubElement(e, 'title')
    content = ET.SubElement(e, 'content')
    content.text = entry.body
    date = ET.SubElement(e, 'date')
    date.text = datetime.datetime.fromtimestamp(entry.created).strftime("%Y-%m-%d %H:%M:%S")
    type = ET.SubElement(e, 'type')
    type.text = 'comment'
    acc.append(e)
    return acc

# Funcion que parsea un post y sus comentarios a XML y devuelve una lista
def get_XML_from_reddit_post(entry):
    acc = []
    e = ET.Element('entry')
    title = ET.SubElement(e, 'title')
    title.text = entry.title
    content = ET.SubElement(e, 'content')
    content.text = entry.selftext
    date = ET.SubElement(e, 'date')
    date.text = datetime.datetime.fromtimestamp(entry.created).strftime("%Y-%m-%d %H:%M:%S")
    type = ET.SubElement(e, 'type')
    type.text = 'post'
    acc.append(e)
    for comment in entry.comments:
        if isinstance(comment, praw.models.MoreComments):
            continue
        get_XML_from_reddit_comment(comment, acc)
    return acc

# Funcion que lee un XML de posts/comentarios de un fichero y devuelve una lista con sus contenidos
def get_XML_content_as_list_from_file(filename):
    parser = ET.XMLParser(encoding = 'utf-8')
    root = ET.parse(filename, parser = parser).getroot()
    result = []
    for entry in root:
        if entry.find('content').text != None:
            result.append(entry.find('content').text)
        elif entry.find('title').text != None:
            result.append(entry.find('title').text)
    return result

# Funcion que devuelve los n terminos centrales de un corpus
def get_central_terms_from_corpus(corpus, n = 10):
    vectorizer = TfidfVectorizer(stop_words = 'english', min_df = 10)
    tfidf = vectorizer.fit_transform(corpus)
    acc_sum = np.sum(tfidf, axis = 0)
    top_positions = np.argsort(-acc_sum).A1[:n]
    terms = []
    feature_names = vectorizer.get_feature_names()
    for pos in top_positions:
        terms.append(feature_names[pos])
    return terms

# Funcion que devuelve los n terminos mas repetidos de un corpus
def get_most_repeated_terms_from_corpus(corpus, n = 100):
    vectorizer = CountVectorizer(stop_words = 'english', min_df = 10)
    count = vectorizer.fit_transform(corpus)
    acc_sum = np.sum(count, axis = 0)
    top_positions = np.argsort(-acc_sum).A1[:n]
    terms = []
    feature_names = vectorizer.get_feature_names()
    for pos in top_positions:
        terms.append(feature_names[pos])
    return terms

def main(argv):
    subreddit = SUBREDDIT
    content_type = CONTENT_TYPE
    n = N
    filename = FILENAME
    try:
        opts, args = getopt.getopt(argv, 'hs:t:n:f:', ['help', 'subreddit=', 'content-type=', 'num-posts=', 'file='])
    except getopt.GetoptError:
        print ('TGINE_S1.py [-s <subreddit>] [-t <content(hot, new)>] [-n <posts number] [-f <filename>]')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print ('TGINE_S1.py [-s <subreddit>] [-t <content(hot, new)>] [-n <posts number] [-f <filename>]')
            sys.exit(0)
        elif opt in ('-s, --subreddit'):
            subreddit = arg
        elif opt in ('-t', '--content-type'):
            content_type = arg
        elif opt in ('-n', '--num-posts'):
            n = int(arg)
        elif opt in ('-f', '--file'):
            filename = arg
    # Realizar la conexion al api de reddit
    reddit = praw.Reddit(client_id = CLIENT_ID, client_secret = CLIENT_SECRET,
                         user_agent = USER_AGENT, username = USERNAME, password = PASSWORD)
    # Recuperamos el contenido de reddit, lo normalizamos y lo guardamos en un fichero
    # Guardamos una lista de ids de post para no meter repetidos
    postIds = []
    e = ET.Element('entryList')
    if content_type == 'hot':
        for post in get_hot_content(reddit, subreddit, n):
            if post.id not in postIds:
                e.extend(get_XML_from_reddit_post(post))
                postIds.append(post.id)
    else:
        for post in get_new_content(reddit, subreddit, n):
            if post.id not in postIds:
                e.extend(get_XML_from_reddit_post(post))
                postIds.append(post.id)
    f = open(filename, 'w')
    print(ET.tostring(e).decode('utf-8'), file = f)
    f.close()
    # Recuperamos el contenido del fichero
    corpus = get_XML_content_as_list_from_file(filename)
    # Mostramos los 10 terminos centrales
    print('10 terminos centrales para el subreddit {} tras analizar {} posts de {} y sus comentarios ({} documentos en total)'.format(subreddit, n, content_type, len(corpus)))
    print(get_central_terms_from_corpus(corpus))
    # Mostramos los 100 terminos mas repetidos
    print('100 terminos mas repetidos en el subreddit {} tras analizar {} posts de {} y sus comentarios ({} documentos en total)'.format(subreddit, n, content_type, len(corpus)))
    print(get_most_repeated_terms_from_corpus(corpus))


if __name__ == "__main__":
    main(sys.argv[1:])
