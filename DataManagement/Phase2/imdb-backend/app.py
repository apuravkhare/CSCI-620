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
        query_string = 'SELECT name.primaryName FROM name, movie, principalCast \n'\
        ' WHERE name.primaryName = principalCast.primaryName \n'\
        ' AND name.birthYear = principalCast.birthYear AND principalCast.category = \'actor\' \n'\
        ' AND movie.startYear NOT IN (SELECT startYear FROM movie WHERE startYear <> {1}) \n'.format(y) \
        ' AND name.deathYear IS NULL AND principalCast.primaryTitle = movie.primaryTitle \n'\
        ' AND principalCast.originalTitle = movie.originalTitle AND principalCast.startYear = movie.startYear \n'\
        ' AND name.primaryName LIKE \'{1}%\''.format(phrase)
    elif query_request.scenario_id == 2:
        pass
    elif query_request.scenario_id == 3:
        for key in query_request.filters.keys():
            if key=="originalTitle":
                phrase = query_request.filters.get(key)
                phrase = phrase.replace("'", "''")
        query_string = 'SELECT avg(runtimeInMinutes) FROM movie, title,writers, name \n'\
        ' WHERE movie.primaryTitle = title.primaryTitle \n'\
        ' AND movie.originalTitle = title.originalTitle AND movie.startYear = title.startYear \n'\
        ' AND writers.primaryTitle = title.primaryTitle AND writers.originalTitle = title.originalTitle \n'\
        ' AND writers.startYear = title.startYear AND writers.primaryName = name.primaryName \n'\
        ' AND writers.birthYear = name.birthYear AND name.deathYear IS NULL \n'\
        ' AND movie.originalTitle LIKE \'%{1}%\''.format(phrase)
    elif query_request.scenario_id==4:
        query_string ='SELECT name.primaryName from name, movie, title, principalCast \n'\
        ' WHERE principalCast.primaryName = name.primaryName \n'\
        ' AND principalCast.birthYear = name.birthYear \n'\
        ' AND principalCast.primaryTitle = title.primaryTitle \n'\
        ' AND principalCast.originalTitle = title.originalTitle \n'\
        ' AND principalCast.startYear = title.startYear \n'\
        ' AND movie.primaryTitle = title.primaryTitle \n'\
        ' AND movie.originalTitle = title.originalTitle \n'\
        ' AND movie.startYear = title.startYear \n'\
        ' AND title.runtimeInMinutes > 120 \n'\
        ' AND name.deathYear IS NULL \n'\
        ' GROUP BY name.primaryName \n'\
        ' HAVING count(movie.originalTitle) >=  \n'\
        ' (SELECT COUNT(movie.originalTitle) AS totalcounts FROM name n, movie m, title t, principalCast p \n'\
        ' WHERE p.primaryName = n.primaryName \n'\
        ' AND p.birthYear = n.birthYear \n'\
        ' AND p.primaryTitle = t.primaryTitle \n' \
        ' AND p.originalTitle = t.originalTitle \n'\
        ' AND p.startYear = t.startYear \n'\
        ' AND m.primaryTitle = t.primaryTitle \n'\
        ' AND m.originalTitle = t.originalTitle \n'\
        ' AND m.startYear = t.startYear \n'\
        ' AND t.runtimeInMinutes > 120 \n'\
        ' AND n.deathYear IS NULL \n'\
        ' GROUP BY n.primaryName) '
    elif query_request.scenario_id ==5:
        for key in query_request.filters.keys():
            if key=="count":
                count = query_request.filters.get(key)
        query_string = 'SELECT Aname.primaryName, Bname.primaryName, AVG(averageRating) \n'\
        ' FROM name Aname,name Bname, movie, title, principalCast Apc, principalCast Bpc \n'\
        ' WHERE Aname.primaryName = Apc.primaryName \n'\
        ' AND Aname.birthYear = Apc.birthYear \n'\
        ' AND Bname.primaryName = Bpc.primaryName \n'\
        ' AND Bname.birthYear = Bpc.birthYear \n'\
        ' AND Aname.birthYear <> Bname.birthYear \n'\
        ' AND Aname.primaryName <> Bname.primaryName \n'\
        ' AND movie.originalTitle = title.originalTitle \n' \
        ' AND movie.primaryTitle = title.primaryTitle \n' \
        ' AND movie.startYear = title.startYear \n' \
        ' AND Apc.originalTitle = title.originalTitle \n' \
        ' AND Apc.primaryTitle = title.primaryTitle \n' \
        ' AND Apc.startYear = title.startYear \n'\
        ' AND Bpc.originalTitle = title.originalTitle \n'\
        ' AND Bpc.primaryTitle = title.primaryTitle\n'\
        ' AND Bpc.startYear = title.startYear \n'\
        ' GROUP BY Aname.primaryName, Bname.primaryName\n'\
        ' HAVING COUNT(movie.originalTitle)>={1}'.format(count)
    elif query_request.scenario_id ==6:
        for key in query_request.filters.keys():
            if key=="count":
                count=query_request.filters.get(key)
            if key=="genre":
                genre=query_request.filters.get(key)
        query_string = 'SELECT n.primaryName FROM name n\n'\
        'inner join principalCast pc on pc.primaryName = n.primaryName and pc.birthYear = n.birthYear\n'\
        'inner join movie m on m.originalTitle = pc.originalTitle and m.primaryTitle = pc.primaryTitle and m.startYear = pc.startYear\n'\
        'inner join titleGenres tg on tg.originalTitle = m.originalTitle and tg.primaryTitle = m.primaryTitle and tg.startYear = m.startYear\n'\
        'where tg.genre = \'{1}\' and m.movieType = \'movie\' and pc.category = \'actor\'\n'\
        'group by n.primaryName, n.birthYear\n'\
        'having COUNT(CONCAT(pc.originalTitle, pc.primaryTitle, pc.startYear)) > {2};'.format(genre, count)
    elif query_request.scenario_id==7:
        for key in query_request.filters.keys():
            if key=="count":
                count=query_request.filters.get(key)
        query_string='select n.primaryName as actor, d.primaryName as director, d.originalTitle, m.movieType\n'\
        'from name n\n'\
        'inner join principalCast pc on pc.primaryName = n.primaryName and pc.birthYear = n.birthYear\n'\
        'inner join directors d on d.originalTitle = pc.originalTitle and d.startYear = pc.startYear\n'\
        'inner join movie m on m.originalTitle = d.originalTitle and m.primaryTitle = d.primaryTitle and m.startYear = d.startYear\n'\
        'where pc.category = \'actor\'\n'\
        'group by n.primaryName, n.birthYear, d.primaryName, d.birthYear\n'\
        'having COUNT(CONCAT(d.originalTitle, d.primaryTitle, d.startYear)) > {1}'.format(count)
    elif query_request.scenario_id==8:
        query_string='select e.originalTitle, e.startYear, t.averageRating\n'\
        'from tvEpisode e\n'\
        'inner join title t on e.originalTitle = t.originalTitle and e.primaryTitle = t.primaryTitle and e.startYear = t.startYear\n'\
        'inner join ( select s.originalTitle, s.primaryTitle, s.startYear, MAX(t.averageRating) as maxRating\n'\
        'from tvEpisode e\n'\
        'inner join title t on e.originalTitle = t.originalTitle and e.primaryTitle = t.primaryTitle and e.startYear = t.startYear\n'\
        'inner join tvSeries s on s.originalTitle = e.seriesOriginalTitle and s.primaryTitle = e.seriesPrimaryTitle and s.startYear = e.seriesStartYear\n'\
        'where s.endYear is not null and s.startYear <> s.endYear\n'\
        'group by e.startYear ) r on r.originalTitle = e.seriesOriginalTitle and r.primaryTitle = e.seriesPrimaryTitle and r.startYear = e.seriesStartYear\n'\
        'where t.averageRating = r.maxRating;'
    elif query_request.scenario_id==9:
        for key in query_request.filters.keys():
            if key=="count":
                count=query_request.filters.get(key)
        query_string='select w.primaryName as writer, d.primaryName as director\n'\
        'from writers w\n'\
        'inner join directors d on d.originalTitle = d.originalTitle and d.startYear = w.startYear\n'\
        'inner join tvSeries s on s.originalTitle = d.originalTitle and s.startYear = d.startYear\n'\
        'group by w.primaryName, w.birthYear, d.primaryName, d.birthYear\n'\
        'having COUNT(CONCAT(d.originalTitle, d.primaryTitle, d.startYear)) > {1};'.format(count)
    elif query_request.scenario_id==10:
        for key in query_request.filters.keys():
            if key=="startYear":
                startYear=query_request.filters.get(key)
            if key=="endYear":
                endYear=query_request.filters.get(key)
        query_string = 'select s.originalTitle, s.primaryTitle, s.startYear\n'\
        'from tvSeries s\n'\
        'inner join title t on s.originalTitle = t.originalTitle and s.primaryTitle = t.primaryTitle and s.startYear = t.startYear\n'\
        'inner join ( select t.startYear, MAX(t.averageRating) as maxRating\n'\
        'from title t\n'\
        'inner join tvSeries s on s.originalTitle = t.originalTitle and s.primaryTitle = t.primaryTitle and s.startYear = t.startYear\n'\
        'where s.endYear is not null and s.startYear between {1} and {2} ) r on r.startYear = s.startYear\n'\
        'where t.averageRating = r.maxRating;'.format(startYear, endYear)
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
