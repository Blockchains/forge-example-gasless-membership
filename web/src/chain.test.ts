import { describe, it, expect } from "vitest";
import { entryPointStatus, accountStatus, ENTRYPOINT_V09 } from "./chain";
import artifacts from "./artifacts.json";
describe("live Sepolia reads", () => {
  it("finds the canonical v0.9 EntryPoint deployed", async () => {
    const s = await entryPointStatus();
    expect(s.deployed).toBe(true);
    expect(s.codeBytes).toBeGreaterThan(1000);
  }, 30000);
  it("reads deposit + nonce for the EntryPoint itself", async () => {
    const r = await accountStatus(ENTRYPOINT_V09);
    expect(Number(r.deposit)).toBeGreaterThanOrEqual(0);
  }, 30000);
  it("ships deployable bytecode from forge build", () => {
    for (const k of ["MembershipNFT", "ClubPaymaster", "SimpleAccountFactory"] as const) expect(artifacts[k].bytecode.length).toBeGreaterThan(1000);
  });
});
