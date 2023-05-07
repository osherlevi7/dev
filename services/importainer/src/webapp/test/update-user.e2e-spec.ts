import { Test, TestingModule } from '@nestjs/testing'
import { Connection } from 'typeorm'
import { NestExpressApplication } from '@nestjs/platform-express'

import * as request from 'supertest'
// import jwt_decode from 'jwt-decode'

import { AppModule } from './app.module'
import { configureApp } from '../src/main.app'
import { StripeService } from '../src/payments/services/stripe.service'
// import { GoogleOAuth2Service } from '../src/auth/google.service'
import { CronService } from '../src/cron/cron.service'

/**
 * User: 101, 102, 103
 * Account: 201 => users 101, 102
 *          211 => user 111
 * Plans: 401, 402, 403
 * Payments: 501 => user 101
 */
const DB_INIT: string = `
TRUNCATE accounts;
TRUNCATE accounts_users;
TRUNCATE users;
TRUNCATE users_credentials;
TRUNCATE plans;
TRUNCATE payments;
TRUNCATE settings;

INSERT INTO settings VALUES (1,'website','{"name": "Uplom", "domain_primary": "uplom.com"}', NOW(), NOW());
INSERT INTO users (id, email, password, isAdmin, isActive, emailConfirmationToken, resetPasswordToken,data, created) VALUES (101,'admin@uplom.com','password',1,1,1,1,'{"profile":{}}', '2021-04-24 13:24:10'),(102,'user@gmail.com','password',0,1,1,'1k-X4PTtCQ7lGQ','{"resetPasswordToken": "1k-X4PTtCQ7lGQ", "resetPasswordTokenExp": "1708940883080", "profile": {}}','2021-04-24 13:24:10'),(111,'nosub@gmail.com','password',0,1,1,1,'{}','2021-04-24 13:24:10');
INSERT INTO accounts (id, owner_id, data) VALUES (201, 101, '{}'),(211, 111, '{}');
INSERT INTO accounts_users (account_id, user_id) VALUES (201, 101),(201, 102),(211, 111);
INSERT INTO users_credentials (credential, userId, json) VALUES ('admin@uplom.com',101,'{"encryptedPassword": "$2b$12$lQHyC/s1tdH1kTwrayYyUOISPteINC5zbHL2eWL6On7fMtIgwYdNm"}');
INSERT INTO users_credentials (credential, userId, json) VALUES ('user@gmail.com',102,'{"encryptedPassword": "$2b$12$lQHyC/s1tdH1kTwrayYyUOISPteINC5zbHL2eWL6On7fMtIgwYdNm"}');
INSERT INTO users_credentials (credential, userId, json) VALUES ('nosub@gmail.com',111,'{"encryptedPassword": "$2b$12$lQHyC/s1tdH1kTwrayYyUOISPteINC5zbHL2eWL6On7fMtIgwYdNm"}');
`

const existingUser = 'email=admin@uplom.com&password=password'

let agent: any

jest.setTimeout(1000 * 60 * 10)

// const envFile = '../env/env.local'
// const secretsFile = '../env/secrets.local'

describe('Timezones', () => {
  it('should always be UTC', () => {
    expect(new Date().getTimezoneOffset()).toBe(0)
  })
})

describe('Update user (e2e)', () => {
  let app: NestExpressApplication
  // let settingsService: SettingsService

  const mockedStripe = {
    client2: {},
    client: {
      customers: {
        retrieve: jest.fn(_ => {
          return ({
            subscriptions: {
              data: [
                { id: 'sub_2', status: 'active', active: 'false' },
                { id: 'sub_3', status: 'active', active: 'true' }
              ]
            }
          })
        }),
        create: jest.fn(_ => {
          return ({
          })
        }),
        update: jest.fn(_ => {})
      },
      paymentMethods: {
        attach: jest.fn(_ => {})
      },
      products: {
        create: jest.fn(_ => {})
      },
      prices: {
        create: jest.fn(_ => {})
      }
    }
  }

  const mockedCronService = {
    setupCron: jest.fn(_ => {})
  }

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule]
    })
      .overrideProvider(StripeService).useValue(mockedStripe)
      // .overrideProvider(GoogleOAuth2Service).useValue(mockedGoogle)
      .overrideProvider(CronService).useValue(mockedCronService)
      .compile()

    app = moduleFixture.createNestApplication()
    configureApp(app, true)
    await app.init()

    const db = app.get(Connection)
    let query: string
    for (query of DB_INIT.split(';')) {
      if (query.trim() !== '') {
        await db.query(query)
      }
    }

    agent = await request(app.getHttpServer())
  })

  afterAll(async () => {
    await app.close()
  })

  it('should update a user', done => {
    const name = 'updated'

    return agent
      .post('/api/v1/login')
      .send(existingUser)
      .expect(302)
      .then(res => {
        agent
          .put('/api/v1/user/101')
          .set('Cookie', res.header['set-cookie'])
          .send({ name })
          .then(res => {
            agent
              .get('/api/v1/team/users')
              .set('Cookie', res.header['set-cookie'])
              .send()
              .expect(200)
              .then(res => {
                try {
                  const { profile } = res.body.message[0]
                  expect(profile.name).toBe(name)
                  return done()
                } catch (err) {
                  console.log('err', err)
                  return done(err)
                }
              })
          })
      })
  })
})
