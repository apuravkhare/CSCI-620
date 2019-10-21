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


@app.route('/get_data', methods=['POST'])
def get_data():
    query = ""
    request_data = json.loads(request.data)
    query_request = QueryRequest(request.get_json().get('scenario_id'), request.get_json().get('filters'))
    if query_request.scenario_id == 1:
        pass
    else:
        query = get_default_query(query_request)

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

