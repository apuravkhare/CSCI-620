import React, { Component } from 'react';
import { Table } from 'react-bootstrap';

/**
 * Displays the result as a table.
 */
class TableDisplay extends Component {
  /**
   * Renders the headers and rows.
   */
    render() {
        return (
          <div>
          {
            this.props.rowData.length === 0 ? <div className="text-center"> No rows to display. </div> :
            <Table striped bordered hover size="sm">
              {this.getHeaders()}
              {this.getRows()}
            </Table>
          }
          </div>
        );
      }

      /**
       * JSX for the headers.
       */
      getHeaders() {
        return (
        <thead>
          <tr key="-1">
          {
            this.props.headers.map((header, index) => <th key={index}>{header}</th>)
          }
          </tr>
        </thead>
        );
      }

      /**
       * JSX for the rows.
       */
      getRows() {
        return (
          <tbody>
            {
              this.props.rowData.map((row, index) => <tr key={index}>{
                row.map((val, dataIndex) => <td key={'' + index + '-' + dataIndex}>{val}</td>)
              }</tr>)
            }
          </tbody>
        );
      }
}

export default TableDisplay;