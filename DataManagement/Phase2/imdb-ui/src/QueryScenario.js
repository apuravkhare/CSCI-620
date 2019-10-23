import React, { Component } from 'react';
import TableDisplay from './TableDisplay';
import { Button, Modal, Navbar, Spinner } from 'react-bootstrap';
import FilterCreator from './FilterCreator';

/**
 * Contains the functionality to view, execute, and modify a query scenario.
 */
class QueryScenario extends Component {

    constructor(props) {
        super(props);
        this.state ={
            queryString: '',
            columns: [],
            data: [],
            isExecuting: true,
            displayQueryModal: false,
            displayErrorsModal: false,
            displayFiltersModal: false,
            errorMessage: null,
            appliedFilters: this.createAppliedFilters()
        }
    }

    /**
     * The main display of the query scenario, containing:
     * Description, Result table, Apply Filters, View Query, and Execute.
     * Handles network errors as well.
     */
    render() {
        return (
            <div>
                <h5 className="px-2 pt-2">
                    Description:
                </h5>
                <div className="px-2 pb-2">
                    {this.props.desc}
                </div>
                <h5 className="px-2 pt-2">
                    Result:
                </h5>
                <div className="px-2">
                    <TableDisplay headers={this.state.columns || []} rowData={this.state.data || []}>
                    </TableDisplay>
                </div>
                <Navbar fixed="bottom">
                        <Button className="mx-1" variant="info"
                        onClick={() => this.setState({displayFiltersModal: true})}
                        disabled={this.state.isExecuting || !this.props.applicableFilters }>
                            Apply Filters
                            </Button>
                        <Button className="mx-1"variant="info" onClick={() => this.setState({displayQueryModal: true})}
                        disabled={this.state.isExecuting}>View Query</Button>
                        <Button className="mx-1"variant="success"
                        onClick={() => this.fetchData()} disabled={this.state.isExecuting}>
                        <div>
                                {
                                    this.state.isExecuting ? 
                                    <div>
                                    <Spinner
                                    as="span"
                                    animation="border"
                                    size="sm"
                                    role="status"
                                    aria-hidden="true"
                                    variant="light"
                                  /> Execute </div> : <div>Execute</div>
                                }
                            </div>
                            </Button>
                </Navbar>
                {this.getQueryModal()}
                {this.getErrorModal()}
                {this.getFilterCreatorModal()}
                
            </div>
        );
    }

    /**
     * Called on init; fetches data from the server.
     */
    componentDidMount() {
        // used the below to test without blocking the UI.
        // this.setState({
        //     queryString: 'result.query',
        //     columns: ['A', 'B', 'C'],
        //     data: [[1,2,3],[4,5,6]],
        //     isExecuting: false
        // });
        this.fetchData();
    }

    /**
     * Makes the API call to fetch the data, update the state, and handle errors.
     */
    fetchData() {
        this.setState({ isExecuting: true });
        const request = {
            scenario_id: this.props.scenarioId,
            filters: this.state.appliedFilters
        };
        console.log('Request: ' + JSON.stringify(request));
        window.fetch('http://127.0.0.1:5000/get_data', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(request)
            })
            .then(res => res.json())
            .then((result) => {
                this.setState({
                    queryString: result.query,
                    columns: result.columns,
                    data: result.data,
                    isExecuting: false,
                    displayErrorsModal: false,
                    errorMessage: null
                });
            },
            (error) => {
                this.setState({
                    isExecuting: false,
                    displayErrorsModal: true,
                    errorMessage: error && error.toString()
                })
            })
    }

    /**
     * JSX for the modal that displays query strings.
     */
    getQueryModal() {
        return(
        <Modal show={this.state.displayQueryModal} onHide={() => this.setState({displayQueryModal: false})} centered>
            <Modal.Header closeButton>
                <Modal.Title>Query String</Modal.Title>
            </Modal.Header>
            <Modal.Body>
                <div>
                {this.state.queryString ? this.state.queryString : 'No query to display.'}
                </div>
            </Modal.Body>
            <Modal.Footer>
                <Button variant="secondary" onClick={() => this.setState({displayQueryModal: false})}>
                    Close
                </Button>
            </Modal.Footer>
        </Modal>
        );
    }

    /**
     * JSX for the modal that displays error messages.
     */
    getErrorModal() {
        return(
        <Modal show={this.state.displayErrorsModal} onHide={() => this.setState({displayErrorsModal: false})} centered>
            <Modal.Header closeButton>
                <Modal.Title>Error</Modal.Title>
            </Modal.Header>
            <Modal.Body>
                <div>
                {this.state.errorMessage}
                </div>
            </Modal.Body>
            <Modal.Footer>
                <Button variant="secondary" onClick={() => this.setState({displayErrorsModal: false})}>
                    Close
                </Button>
            </Modal.Footer>
        </Modal>
        );
    }

    /**
     * JSX for the filter modal.
     */
    getFilterCreatorModal() {
        return(
            <Modal show={this.state.displayFiltersModal} onHide={() => this.setState({displayFiltersModal: false})} centered>
                <Modal.Header closeButton>
                    <Modal.Title>Select Filters</Modal.Title>
                </Modal.Header>
                <Modal.Body>
                    <FilterCreator applicableFilters={this.props.applicableFilters}
                    appliedFilters={this.state.appliedFilters}></FilterCreator>
                </Modal.Body>
                <Modal.Footer>
                    <Button variant="secondary" onClick={() => this.setState({displayFiltersModal: false})}>
                        Close
                    </Button>
                </Modal.Footer>
            </Modal>
            );
    }

    /**
     * Maps the applicable filters to applied filters.
     */
    createAppliedFilters() {
        const appliedFilters = {};
        if (this.props.applicableFilters) {
            Object.keys(this.props.applicableFilters).forEach(filterColumn => {
                appliedFilters[filterColumn] = this.props.applicableFilters[filterColumn].default || null;
            })
        }
        
        return appliedFilters;
    }
}

export default QueryScenario;