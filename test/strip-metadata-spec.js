const { assert } = require('chai');
const types = require('leadconduit-types');
const strip = require('../lib/strip-metadata');

describe('Strip metadata', function() {

  beforeEach(function() {
    this.vars = {
      submission: {
        timestamp: '2019-02-27T08:02:53.669Z'
      },
      account: {
        id: 'account123',
        name: 'Lead Garden, Inc.',
        sso_id: 'sso123'
      },
      flow: {
        id: 'flow123',
        name: 'Sales Leads'
      },
      random: 24,
      source: {
        id: 'source123',
        name: 'Contact Form'
      },
      to: 'delivery@example.com',
      cc: 'customer@example.com',
      lead: {
        id: 'lead123',
        email: types.email.parse('dee@leadgarden.com'),
        first_name: 'Dee',
        last_name: 'Daniels',
        phone_1: types.phone.parse('512-555-1212'),
        trustedform_cert_url: types.url.parse('https://cert.trustedform.com/cert123')
      },
      suppression_list: {
        query_item: {
          key: 'dee@leadgarden.com',
          found: types.boolean.parse(false),
          reason: null,
          outcome: 'success',
          duration: types.number.parse(0.0123),
          specified_lists: ['sales_leads']
        },
        add_item: {
          reason: null,
          outcome: 'success',
          accepted: types.number.parse(1),
          rejected: types.number.parse(0),
          duration: types.number.parse(0.0456)
        }
      },
      anura: {
        outcome: 'success',
        billable: types.number.parse(1),
        is_suspect: types.boolean.parse(false)
      },
      leadconduit_classic: {
        id: 'classic123'
      }
    };
  });


  it('should strip basic metadata', function() {
    const expected = {
      email: 'dee@leadgarden.com',
      first_name: 'Dee',
      last_name: 'Daniels',
      phone_1: '5125551212',
      trustedform_cert_url: 'https://cert.trustedform.com/cert123',
      to: 'delivery@example.com',
      cc: 'customer@example.com',
      suppression_list: {
        query_item: {
          key: 'dee@leadgarden.com',
          found: false,
          duration: 0.0123,
          specified_lists: ['sales_leads']
        },
        add_item: {
          accepted: 1,
          rejected: 0,
          duration: 0.0456
        }
      },
      anura: {
        is_suspect: false
      },
      leadconduit_classic: {
        id: 'classic123'
      }
    };

    assert.deepEqual(strip(this.vars), expected);
  });


  it('should strip basic metadata plus additional fields', function() {
    const expected = {
      email: 'dee@leadgarden.com',
      first_name: 'Dee',
      last_name: 'Daniels',
      phone_1: '5125551212',
      trustedform_cert_url: 'https://cert.trustedform.com/cert123',
      to: 'delivery@example.com',
      suppression_list: {
        add_item: {
          accepted: 1,
          rejected: 0
        }
      },
      anura: {
        is_suspect: false
      },
      leadconduit_classic: {
        id: 'classic123'
      }
    };

    assert.deepEqual(strip(this.vars, [new RegExp('query_item.*'), new RegExp('.*.duration'), 'cc']), expected);
  });
});
