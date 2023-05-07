import { TypeOrmModuleOptions } from '@nestjs/typeorm'

export const DB_CONFIG: TypeOrmModuleOptions = {
  type: 'mariadb',
  // dropSchema: true,
  host: '192.168.50.242',
  port: 3306,
  username: 'saasform',
  password: 'saasformp',
  database: 'saasform_test',
  autoLoadEntities: true,
  // synchronize: true,
  entities: ['*.entity.ts']
}
