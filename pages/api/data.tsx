import { NextApiRequest, NextApiResponse } from "next";
import { check } from "../../src/bucket";

export default async (_req: NextApiRequest, res: NextApiResponse) => {
  const { allowed, remaining } = await check("abcd");
  res.status(200).json({ allowed, remaining });
};
