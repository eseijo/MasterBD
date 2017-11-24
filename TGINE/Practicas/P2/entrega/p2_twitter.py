## Definicion de imports
# Importamos el wrapper del API de twitter
import twitter
# Importamos el parser XML
import xml.etree.ElementTree as ET
# Importamos sys y getopt para poder obtener los parametros de entrada del script
import sys, getopt
# Importamos el CountVectorizer y el TfidfVectorizer
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
# Importamos model_selection para realizar el split entre muestras de entrenamiento y de test
from sklearn import model_selection
# Importamos SVC para realizar la clasificacion
from sklearn.svm import SVC
# Importamos confusion_matrix para obtener la matriz de confusion
from sklearn.metrics import confusion_matrix
# Importamos twokenize para usarlo como tokenizador de tweets
import twokenize
# Importamos pandas para la representacion en linea de comandos de la matriz de confusion como una tabla
import pandas as pd

# Definicion de constantes como las credenciales, el maximo de tweets por peticion, valores por defecto...
CONSUMER_KEY = 'wo8oNmaGUcpF9WGckt62FtHUc'
CONSUMER_SECRET = 'do4NPAweukb41Y8qQZkpGT5IRUiKEAv6MrzYv8tl8u3NDcSK2P'
ACCESS_TOKEN = '2214334652-k6o6ODLsraogVDrcAF39hMo020aBLvwzNUF8DLl'
ACCESS_TOKEN_SECRET = 'odpZZyOlsB0TowICtmEC5LjINAIDSzHjVQolUKi6NAsZi'

MAX_TWEETS_PER_REQUEST = 200

USER_1 = 'Pontifex'
USER_2 = 'DalaiLama'

DEFAULT_VECTORIZER = 'tf-idf'
DEFAULT_TOKENIZER = 'twokenize'
DEFAULT_C = 1.0
DEFAULT_KERNEL = 'rbf'

# Nombre de fichero donde se guardaran los datos extraidos de twitter
FILENAME = 'pyTweetClassifier_data.xml'

# Crear metodo de descarga de tweets que tenga en cuenta las limitaciones de la API
def get_user_time_line(api, user, n = MAX_TWEETS_PER_REQUEST):
    result = None
    if(n <= MAX_TWEETS_PER_REQUEST):
        result = api.GetUserTimeline(screen_name=user, count=n)
    else:
        result = []
        requests = n//MAX_TWEETS_PER_REQUEST if (n%MAX_TWEETS_PER_REQUEST == 0) else (n//MAX_TWEETS_PER_REQUEST) + 1
        max_id = None
        for count in range(1, requests+1):
            if(n < count*MAX_TWEETS_PER_REQUEST):
                res = api.GetUserTimeline(screen_name=user, count=n%MAX_TWEETS_PER_REQUEST, max_id=max_id)
                max_id = res[-1].id
                result = result + res
            else:
                res = api.GetUserTimeline(screen_name=user, count=MAX_TWEETS_PER_REQUEST, max_id=max_id)
                max_id = res[-1].id
                result = result + res
    return result

# Funcion que parsea un tweet a XML y devuelve un elemento ElementTree
def get_XML_from_tweet(tweet):
    e = ET.Element('tweet')
    text = ET.SubElement(e, 'text')
    text.text = tweet.text
    user = ET.SubElement(e, 'user')
    user.text = tweet.user.screen_name
    return e

# Funcion que lee un XML de tweets de un fichero y devuelve un diccionario cuya clave es el nombre de usuario y el valor una lista de sus tweets
def get_XML_content_as_list_from_file(filename):
    parser = ET.XMLParser(encoding = 'utf-8')
    root = ET.parse(filename, parser = parser).getroot()
    result = {}
    for entry in root:
        if entry.find('text').text != None and entry.find('user').text != None:
            result[entry.find('user').text] = result[entry.find('user').text] if entry.find('user').text in result else []
            result[entry.find('user').text].append(entry.find('text').text)
    return result

# Funcion que devuelve un vectorizador del tipo que se le indique
def get_vectorizer(key='tf-idf', tokenizer=None):
    tok = None
    if(tokenizer != None and tokenizer == 'twokenize'):
        tok = twokenize.tokenizeRawTweetText
    if(key == 'tf-idf'):
        return TfidfVectorizer(stop_words='english', tokenizer=tok, min_df=5)
    elif(key == 'count'):
        return CountVectorizer(stop_words='english', tokenizer=tok, min_df=5)
    else:
        return None

# Funcion que, a partir de un corpus de tweets, devuelve muestras de entrenamiento y test ademas de sus resultados (a que clase pertenece cada muestra)
def get_train_and_test_samples(corpus):
    user_class = 0
    tweets = []
    results = []
    for user, l in corpus.items():
        for tweet in l:
            tweets.append(tweet)
            results.append(user_class)
        user_class = user_class + 1

    return model_selection.train_test_split(tweets, results, test_size=0.2)

# Funcion que, a partir de un corpus de tweets y un lexicon, devuelve el numero total de terminos, el numero de positivos y el de negativos
def get_positives_and_negatives(corpus, lexicon):
    num_words = {}
    num_positive_words = {}
    num_negative_words = {}
    for user, l in corpus.items():
        for tweet in l:
            for token in twokenize.tokenizeRawTweetText(tweet):
                num_words[user] = num_words[user] if user in num_words else 0
                num_words[user] = num_words[user] + 1
                if token in lexicon['positive']:
                    num_positive_words[user] = num_positive_words[user] if user in num_positive_words else 0
                    num_positive_words[user] = num_positive_words[user] + 1
                elif token in lexicon['negative']:
                    num_negative_words[user] = num_negative_words[user] if user in num_negative_words else 0
                    num_negative_words[user] = num_negative_words[user] + 1
    return num_words, num_positive_words, num_negative_words


def main(argv):
    user1 = USER_1
    user2 = USER_2
    n = MAX_TWEETS_PER_REQUEST
    filename = FILENAME
    vect_key = DEFAULT_VECTORIZER
    tokenizer = DEFAULT_TOKENIZER
    c = DEFAULT_C
    kernel = DEFAULT_KERNEL
    degree = 1
    gamma = 1
    try:
        opts, args = getopt.getopt(argv, 'hu1:u2:n:v:t:o:f:', ['help', 'user1=', 'user2=', 'num-tweets=', 'vectorizer=', 'tokenizer=', 'svc-options=', 'file='])
    except getopt.GetoptError:
        print ('p2_twitter.py [-u1 <user1>] [-u2 <user2>] [-n <tweets number>] [-v <vectorizer(count, tf-idf)>] [-t <tokenizer(twokenize)>] '
               '[-o <svc options(C and kernel separated with semicolon)>] [-f <filename>]')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('p2_twitter.py [-u1 <user1>] [-u2 <user2>] [-n <tweets number>] [-v <vectorizer(count, tf-idf)>] [-t <tokenizer(twokenize)>] '
                  '[-o <svc options(C and kernel separated with semicolon)>] [-f <filename>]')
            sys.exit(0)
        elif opt in ('-u1, --user1'):
            user1 = arg
        elif opt in ('-u2', '--user2'):
            user2 = arg
        elif opt in ('-n', '--num-tweets'):
            n = int(arg)
        elif opt in ('-v', '--vectorizer'):
            vect_key = arg
        elif opt in ('-t', '--tokenizer'):
            tokenizer = arg
        elif opt in ('-o', '--svc-options'):
            split = arg.split(';')
            c = float(split[0])
            kernel = split[1]
            if(len(split) > 2):
                degree = int(split[2])
            if(len(split) > 3):
                gamma = float(split[3])
        elif opt in ('-f', '--file'):
            filename = arg
    # Realizar la conexion al api de twitter
    api = twitter.Api(consumer_key=CONSUMER_KEY,
                      consumer_secret=CONSUMER_SECRET,
                      access_token_key=ACCESS_TOKEN,
                      access_token_secret=ACCESS_TOKEN_SECRET,
                      sleep_on_rate_limit=True)
    # Recuperamos el contenido de twitter, lo normalizamos y lo guardamos en un fichero
    e = ET.Element('tweetList')
    for tweet in get_user_time_line(api, user1, n):
        e.append(get_XML_from_tweet(tweet))
    for tweet in get_user_time_line(api, user2, n):
        e.append(get_XML_from_tweet(tweet))
    f = open(filename, 'w')
    print(ET.tostring(e).decode('utf-8'), file=f)
    f.close()
    ## Clasificacion
    # Recuperamos el contenido del fichero
    corpus = get_XML_content_as_list_from_file(filename)
    # Obtenemos los conjuntos de entrenamiento y test
    xTrain, xTest, yTrain, yTest = get_train_and_test_samples(corpus)
    # Obtenemos el vectorizador a partir de los parametros indicados
    vectorizer = get_vectorizer(vect_key, tokenizer)
    # Entrenamos el vectorizador con el conjunto de entrenamiento y obtenemos el vector de tfidf para el conjunto de entrenamiento
    xTrainVect = vectorizer.fit_transform(xTrain)
    # Creamos el clasificador a partir de los parametros indicados
    clf = SVC(C=c, kernel=kernel, degree=degree, gamma=gamma)
    # Entrenamos el clasificador con el conjunto de entrenamiento vectorizado
    clf.fit(xTrainVect, yTrain)
    # Obtenemos el vector de tfidf para el conjunto de test
    xTestVect = vectorizer.transform(xTest)
    # Predecimos los resultados del conjunto de test
    yTestPred = clf.predict(xTestVect)

    matrix = confusion_matrix(yTest, yTestPred)
    df = pd.DataFrame(matrix, ['Real Negativo', 'Real Positivo'], ['Pred. Negativo', 'Pred. Positivo'])

    print('Experimento de clasificacion de tweets de los usuarios {} y {}.'.format(user1, user2))
    print()
    print('Numero de tweets procesados: {}'.format(len(xTrain) + len(xTest)))
    print('Vectorizador: {}. Clasificador: SVC'.format(vect_key))
    print()
    print('Matriz de confusion:')
    print(df)
    print()
    print('Accuracy: {:.2f}%'.format(clf.score(xTestVect, yTest)*100))

    ## Analisis de sentimiento
    # Recuperamos el lexicon de terminos positivos y negativos
    pos_neg_words = {'positive': [], 'negative': []}

    for pos_word in open('positive-words.txt', 'r').readlines()[35:]:
        pos_neg_words['positive'].append(pos_word.rstrip())

    for neg_word in open('negative-words.txt', 'r').readlines()[35:]:
        pos_neg_words['negative'].append(neg_word.rstrip())

    num_words, positives, negatives = get_positives_and_negatives(corpus, pos_neg_words)
    print()
    print('Analisis basico de sentimiento para los tweets de los usuarios {} y {}:'.format(user1, user2))
    print()
    print('Porcentaje de terminos positivos para el usuario {}: {:.2f}%'.format(user1, positives[user1]*100/num_words[user1]))
    print('Porcentaje de terminos negativos para el usuario {}: {:.2f}%'.format(user1, negatives[user1]*100/num_words[user1]))
    print()
    print('Porcentaje de terminos positivos para el usuario {}: {:.2f}%'.format(user2, positives[user2]*100/num_words[user2]))
    print('Porcentaje de terminos negativos para el usuario {}: {:.2f}%'.format(user2, negatives[user2]*100/num_words[user2]))
    print()

if __name__ == "__main__":
    main(sys.argv[1:])
