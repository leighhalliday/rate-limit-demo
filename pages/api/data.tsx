import { NextApiRequest, NextApiResponse } from "next";
// import { check } from "../../src/bucket";

export default async (_req: NextApiRequest, res: NextApiResponse) => {
  res.status(200).json({ allowed: true, remaining: 15 });
};
