from flask import Flask, request, make_response
import pyodbc
import json

app = Flask(__name__)


class QueryRequest:
    def __init__(self, scenario_id, filters):
        # integer
        self.scenario_id = scenario_id
        # dict: string -> object[]
        self.filters = filters


class QueryResponse:
    def __init__(self, query, column_names, data):
        # string
        self.query = query
        # string[]
        self.columns = column_names
        # object[][]
        self.data = data


@app.route('/')
def hello_world():
    return 'Hello World!'


'''
Execute this from the browser console to test the method. The result can be seen in the Network tab.
await window.fetch('http://127.0.0.1:5000/get_data',{
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(x = {
    scenario_id: -1,
    filters: { startYear: [ '2017' ] }
  })
});
'''
@app.route('/get_data', methods=['POST'])
def get_data():
    query = ""
    request_data = json.loads(request.data)
    query_request = QueryRequest(request.get_json().get('scenario_id'), request.get_json().get('filters'))
    
    query = query_gen(query_request, query_request.scenario_id)

    conn = pyodbc.connect('Driver={SQL Server};'
                          'Server=DESKTOP-NAGK15L;'
                          'Database=imdb;'
                          'Trusted_Connection=yes;')

    cursor = conn.cursor()
    cursor.execute(query)

    column_names = [col[0] for col in cursor.description]
    row_data = [[row[col] for col in range(0, len(column_names))] for row in cursor]
    resp_json = json.dumps(QueryResponse(query, column_names, row_data).__dict__)
    return make_response(resp_json, 200)


def get_default_query(query_request: QueryRequest):
    query_string = 'SELECT top 10 * FROM dbo.title'
    query_string += add_filters(query_request.filters)
    return query_string

def query_gen(query_request: QueryRequest):
    query_string=""
    if query_request.scenario_id==1:

        for key in query_request.filters.keys():
            if key=="startYear":
                y = int(query_request.filters.get(key))
            else:
                phrase = query_request.filters.get(key)
                phrase = phrase.replace("'", "''")
        query_string = 'SELECT name.primaryName FROM name, movie, principalCast '\
        ' WHERE name.primaryName = principalCast.primaryName '\
        ' AND name.birthYear = principalCast.birthYear AND principalCast.category = \'actor\' '\
        ' AND movie.startYear NOT IN (SELECT startYear FROM movie WHERE startYear <> {1}) ' \
        ' AND name.deathYear IS NULL AND principalCast.primaryTitle = movie.primaryTitle '\
        ' AND principalCast.originalTitle = movie.originalTitle AND principalCast.startYear = movie.startYear '\
        ' AND name.primaryName LIKE \'{2}%\''.format(y, phrase)
    elif query_request.scenario_id == 2:
        pass
    elif query_request.scenario_id == 3:
        for key in query_request.filters.keys():
            if key=="originalTitle":
                phrase = query_request.filters.get(key)
                phrase = phrase.replace("'", "''")
        query_string = 'SELECT avg(runtimeInMinutes) FROM movie, title,writers, name '\
        ' WHERE movie.primaryTitle = title.primaryTitle '\
        ' AND movie.originalTitle = title.originalTitle AND movie.startYear = title.startYear '\
        ' AND writers.primaryTitle = title.primaryTitle AND writers.originalTitle = title.originalTitle '\
        ' AND writers.startYear = title.startYear AND writers.primaryName = name.primaryName '\
        ' AND writers.birthYear = name.birthYear AND name.deathYear IS NULL '\
        ' AND movie.originalTitle LIKE \'%{1}%\''.format(phrase)
    elif query_request.scenario_id==4:
        query_string ='SELECT name.primaryName from name, movie, title, principalCast '\
        ' WHERE principalCast.primaryName = name.primaryName '\
        ' AND principalCast.birthYear = name.birthYear '\
        ' AND principalCast.primaryTitle = title.primaryTitle '\
        ' AND principalCast.originalTitle = title.originalTitle '\
        ' AND principalCast.startYear = title.startYear '\
        ' AND movie.primaryTitle = title.primaryTitle '\
        ' AND movie.originalTitle = title.originalTitle '\
        ' AND movie.startYear = title.startYear '\
        ' AND title.runtimeInMinutes > 120 '\
        ' AND name.deathYear IS NULL '\
        ' GROUP BY name.primaryName '\
        ' HAVING count(movie.originalTitle) >=  '\
        ' (SELECT COUNT(movie.originalTitle) AS totalcounts FROM name n, movie m, title t, principalCast p '\
        ' WHERE p.primaryName = n.primaryName '\
        ' AND p.birthYear = n.birthYear '\
        ' AND p.primaryTitle = t.primaryTitle ' \
        ' AND p.originalTitle = t.originalTitle '\
        ' AND p.startYear = t.startYear '\
        ' AND m.primaryTitle = t.primaryTitle '\
        ' AND m.originalTitle = t.originalTitle '\
        ' AND m.startYear = t.startYear '\
        ' AND t.runtimeInMinutes > 120 '\
        ' AND n.deathYear IS NULL '\
        ' GROUP BY n.primaryName) '
    elif query_request.scenario_id ==5:
        for key in query_request.filters.keys():
            if key=="count":
                count = query_request.filters.get(key)
        query_string = 'SELECT Aname.primaryName, Bname.primaryName, AVG(averageRating) '\
        ' FROM name Aname,name Bname, movie, title, principalCast Apc, principalCast Bpc '\
        ' WHERE Aname.primaryName = Apc.primaryName '\
        ' AND Aname.birthYear = Apc.birthYear '\
        ' AND Bname.primaryName = Bpc.primaryName '\
        ' AND Bname.birthYear = Bpc.birthYear '\
        ' AND Aname.birthYear <> Bname.birthYear '\
        ' AND Aname.primaryName <> Bname.primaryName '\
        ' AND movie.originalTitle = title.originalTitle ' \
        ' AND movie.primaryTitle = title.primaryTitle ' \
        ' AND movie.startYear = title.startYear ' \
        ' AND Apc.originalTitle = title.originalTitle ' \
        ' AND Apc.primaryTitle = title.primaryTitle ' \
        ' AND Apc.startYear = title.startYear '\
        ' AND Bpc.originalTitle = title.originalTitle '\
        ' AND Bpc.primaryTitle = title.primaryTitle '\
        ' AND Bpc.startYear = title.startYear '\
        ' GROUP BY Aname.primaryName, Bname.primaryName'\
        ' HAVING COUNT(movie.originalTitle)>=2'

    else:
        query_string = get_default_query(query_request)
    return query_string



def add_filters(filters: dict):
    filter_clauses = []

    if filters is None:
        return ''

    for key in filters.keys():
        if len(filters.get(key)) == 1:
            filter_clauses.append(key + ' = ' + filters.get(key)[0])
        elif len(filters.get(key)) > 1:
            filter_clauses.append(key + ' in ' + ','.join(filters))
        else:
            pass
    return ' where ' + ' and '.join(filter_clauses) if len(filter_clauses) > 0 else ''


if __name__ == '__main__':
    app.run()
