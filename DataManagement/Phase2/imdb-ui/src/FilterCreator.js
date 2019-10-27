import React, { Component } from 'react';
import { Col, Form, Row } from 'react-bootstrap';

/**
 * Enables modifying a query scenario by applying filters.
 */
class FilterCreator extends Component {
    /**
     * The modal body.
     */
    render() {
        return (
            <div>
            {this.props.applicableFilters ? this.getFiltersView() : 'No filters to apply.'}
            </div>
        );
    }

    /**
     * Creates form controls for the applicable filters config.
     * Updates the applied filters when necessary.
     */
    getFiltersView() {
        return (
            <Form>
            {
                Object.keys(this.props.applicableFilters).map(filterColumn => 
                    <Form.Group key={filterColumn} as={Row} >
                        <Col>
                            <Form.Label>
                                {filterColumn}
                            </Form.Label>
                        </Col>
                        <Col>
                            <Form.Label>
                                {this.props.applicableFilters[filterColumn].op}
                            </Form.Label>
                        </Col>
                        <Col sm={6}>
                            <Form.Control defaultValue={this.props.appliedFilters[filterColumn]}
                            onChange={(event) => this.props.appliedFilters[filterColumn] = event.target.value } />
                        </Col>
                    </Form.Group>
                )
            }
            </Form>
        )
    }
}

export default FilterCreator;