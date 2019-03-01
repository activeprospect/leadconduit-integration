assert = require('chai').assert
types = require('leadconduit-types')
strip = require('../src/stripMetadata')

describe 'Strip metadata', ->

  beforeEach () ->
    @vars =
      submission:
        timestamp: '2019-02-27T08:02:53.669Z'
      account:
        id: 'account123'
        name: 'Lead Garden, Inc.'
        sso_id: 'sso123'
      flow:
        id: 'flow123'
        name: 'Sales Leads'
      random: 24
      source:
        id: 'source123'
        name: 'Contact Form'
      lead:
        id: 'lead123'
        email: types.email.parse('dee@leadgarden.com')
        first_name: 'Dee'
        last_name: 'Daniels'
        phone_1: types.phone.parse('512-555-1212')
        trustedform_cert_url: types.url.parse('https://cert.trustedform.com/cert123')
      suppression_list:
        query_item:
          key: 'dee@leadgarden.com'
          found: types.boolean.parse(false)
          reason: null
          outcome: 'success'
          duration: types.number.parse(0.0123)
          specified_lists: ['sales_leads']
        add_item:
          reason: null
          outcome: 'success'
          accepted: types.number.parse(1)
          rejected: types.number.parse(0)
          duration: types.number.parse(0.0456)
      anura:
        outcome: 'success'
        billable: types.number.parse(1)
        is_suspect: types.boolean.parse(false)


  it 'should strip basic metadata', ->
    expected =
      email: 'dee@leadgarden.com'
      first_name: 'Dee'
      last_name: 'Daniels'
      phone_1: '5125551212'
      trustedform_cert_url: 'https://cert.trustedform.com/cert123'
      suppression_list:
        query_item:
          key: 'dee@leadgarden.com'
          found: false
          duration: 0.0123
          specified_lists: ['sales_leads']
        add_item:
          accepted: 1
          rejected: 0
          duration: 0.0456
      anura:
        is_suspect: false

    assert.deepEqual(strip(@vars), expected)


  it 'should strip basic metadata plus additional fields', ->
    expected =
      email: 'dee@leadgarden.com'
      first_name: 'Dee'
      last_name: 'Daniels'
      phone_1: '5125551212'
      trustedform_cert_url: 'https://cert.trustedform.com/cert123'
      suppression_list:
        add_item:
          accepted: 1
          rejected: 0
      anura:
        is_suspect: false

    assert.deepEqual(strip(@vars, ['query_item.*', '.*.duration']), expected)
