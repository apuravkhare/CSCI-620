import React, { Component } from 'react';
import './App.css';
import { Tab, Tabs } from 'react-bootstrap';
import QueryScenario from './QueryScenario';

/**
 * The main page. It holds the header tab, and an outlet to the query scenario component.
 */
class App extends Component {
  constructor(props) {
    super(props);
    this.id = 0;
    this.name = null;
  }

  /**
   * The main app,
   */
  render() {
    return (
      <div className="App">
        <Tabs defaultActiveKey="0" id="query-scenarios-tab" mountOnEnter={true} unmountOnExit={true}>
          { this.getTabs() }
        </Tabs>
      </div>
    );
  }

  /**
   * Generates JSX for the query scenarios.
   */
  getTabs() {
    const scenarios = this.getScenarios();
    const scenarioIds = Object.keys(scenarios).map(key => parseInt(key));
    return (
       scenarioIds.map(scenarioId =>
        <Tab key={scenarioId} eventKey={scenarioId} title={scenarios[scenarioId].title}>
          <QueryScenario scenarioId={scenarioId} desc={scenarios[scenarioId].desc}
          applicableFilters={scenarios[scenarioId].applicableFilters} ></QueryScenario>
        </Tab>)
    );
  }

  /**
   * Ideally, this should be the only function that would be updated when a new query scenario is added.
   * The key of the object is the scenarioId, the object contains a title, description, applicable filters
   * with the column name, operator type, and the default value, if any.
   */
  getScenarios() {
    return {
      0: {
        'title': 'Default',
        'desc': 'Top 100 movies of this year.',
      },
      1: {
        'title': 'Scenario 1',
        'desc': 'Alive actors whose name starts with a keyword that have not participated in any movie for a given year.',
        'applicableFilters': {
          'startYear': {
            'op': 'equals',
            'default': '2017'
          },
          'primaryName': {
            'op': 'starts w/',
            'type': 'string',
            'default': 'phi'
          }
        }
      },
      2: {
        'title': 'Scenario 2',
        'desc': 'Alive producers who have produced more than 50 talk shows in a given year, and whose name contains a keyword.',
        'applicableFilters': {
          'startYear': {
            'op': 'equals',
            'default': '2017'
          },
          'primaryName': {
            'op': 'contains',
            'type': 'string',
            'default': 'gi'
          },
          'count': {
            'op': '=',
            'type': 'number',
            'default': '50'
          }
        }
      },
      3: {
        'title': 'Scenario 3',
        'desc': 'Average runtime for movies whose original title contains a given keyword and are written by someone who is still alive.',
        'applicableFilters': {
          'originalTitle': {
            'op': 'contains',
            'type': 'string',
            'default': 'gill'
          }
        }
      },
      4: {
        'title': 'Scenario 4',
        'desc': 'Alive producers with the greatest number of long-run movies produced (runtime > 120 minutes)'
      },
      5: {
        'title': 'Scenario 5',
        'desc': 'Unique actor pairs who have acted together in more than 2 movies, sorted by average movie rating.',
        'applicableFilters': {
          'count': {
            'op': '=',
            'type': 'number',
            'default': 2
          }
        }
      },
      6: {
        'title': 'Scenario 6',
        'desc': 'Actors that have worked in a given number of movies of a certain genre',
        'applicableFilters': {
          'genre': {
            'op': 'equals',
            'type': 'string',
            'default': 'horror'
          },
          'count': {
            'op': 'equals',
            'type': 'number',
            'default': '10'
          }
        }
      },
      7: {
        'title': 'Scenario 7',
        'desc': 'Actors and directors that have worked together certain number of times in titles that are not tv shows and the titles that they have worked in together',
        'applicableFilters': {
          'count': {
            'op': 'equals',
            'type': 'number',
            'default': '5'
          }
        }
      },
      8: {
        'title': 'Scenario 8',
        'desc': 'The highest rated episodes of shows that have spanned more than one year and have ended, by year sorted highest to lowest',
      },
      9: {
        'title': 'Scenario 9',
        'desc': 'Writers and directors that have worked together in atleast a certain number of different TV Shows',
        'applicableFilters': {
          'count': {
            'op': 'equals',
            'type': 'number',
            'default': '5'
          }
        }
      },
      10: {
        'title': 'Scenario 10',
        'desc': 'The most popular TV shows by year, between two years that are still running',
        'applicableFilters': {
          'startYear': {
            'op': 'equals',
            'type': 'number',
            'default': '2017'
          },
          'endYear': {
            'op': 'equals',
            'type': 'number',
            'default': '2019'
          }
        }
      }
    }
  }
}

export default App;
