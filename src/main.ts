import { Logger } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Graceful shutdown: lets the container drain in-flight requests on SIGTERM
  // (sent by ECS when a task is stopped/replaced).
  app.enableShutdownHooks();

  const port = process.env.PORT ?? 3000;
  await app.listen(port, '0.0.0.0');

  Logger.log(`Application is running on: http://0.0.0.0:${port}`, 'Bootstrap');
}

void bootstrap();
