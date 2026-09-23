import { Injectable, NestMiddleware } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { NextFunction, Request, Response } from 'express';

@Injectable()
export class RequestIdMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const requestId =
      typeof req.headers['x-request-id'] === 'string' ? req.headers['x-request-id'] : randomUUID();
    res.locals.requestId = requestId;
    res.setHeader('X-Request-Id', requestId);
    next();
  }
}
