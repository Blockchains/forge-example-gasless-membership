import { createPublicClient, http, formatEther, parseAbi, type Address } from "viem";
import { sepolia } from "viem/chains";
export const ENTRYPOINT_V09: Address = "0x433709009B8330FDa32311DF1C2AFA402eD8D009";
export const epAbi = parseAbi([
  "function balanceOf(address account) view returns (uint256)",
  "function getNonce(address sender, uint192 key) view returns (uint256)",
  "function supportsInterface(bytes4 interfaceId) view returns (bool)",
]);
export const publicClient = createPublicClient({ chain: sepolia, transport: http("https://ethereum-sepolia-rpc.publicnode.com") });
export async function entryPointStatus() {
  const [code, block] = await Promise.all([publicClient.getCode({ address: ENTRYPOINT_V09 }), publicClient.getBlockNumber()]);
  return { deployed: !!code && code !== "0x", codeBytes: code ? (code.length - 2) / 2 : 0, block };
}
export async function accountStatus(a: Address) {
  const [dep, nonce] = await Promise.all([
    publicClient.readContract({ address: ENTRYPOINT_V09, abi: epAbi, functionName: "balanceOf", args: [a] }),
    publicClient.readContract({ address: ENTRYPOINT_V09, abi: epAbi, functionName: "getNonce", args: [a, 0n] }),
  ]);
  return { deposit: formatEther(dep), nonce };
}
