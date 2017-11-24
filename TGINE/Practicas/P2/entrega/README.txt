Para ejecutar el script:

p2_twitter.py [-u1 <user1>] [-u2 <user2>] [-n <tweets number>] [-v <vectorizer(count, tf-idf)>] [-t <tokenizer(twokenize)>] [-o <svc options(C, kernel and degree separated with semicolon)>] [-f <filename>]

Si no se especifica alguno de los parámetros, tomarán valores por defecto y la ejecución de:

python p2_twitter.py

se correspondería a ejecutar:

python p2_twitter.py -u1 Pontifex -u2 DalaiLama -n 200 -v tf-idf -t twokenize -o 1.0;rbf -f pyTweetClassifier_data.xml
