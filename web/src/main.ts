import { createWalletClient, custom, isAddress, parseEther, type Address, type Hex } from "viem";
import { sepolia } from "viem/chains";
import artifacts from "./artifacts.json";
import map from "./component-map.json";
import { ENTRYPOINT_V09, entryPointStatus, accountStatus, publicClient } from "./chain";

const $ = (id: string) => document.getElementById(id)!;
$("idea").textContent = map.idea;
$("lic").innerHTML = `Project licence: <b>${map.license.project_license}</b>${map.license.warning ? ` <span class="warn">(${map.license.warning})</span>` : ""}`;
const tb = $("map").querySelector("tbody")!;
for (const s of map.selected as any[]) {
  const tr = document.createElement("tr");
  tr.innerHTML = `<td>${s.capability}</td><td><a href="https://github.com/${s.fork}/blob/${s.commit}/${s.path}">${s.name}</a><br><span class="mono">${s.path}</span></td><td><a href="https://github.com/${s.fork}">${s.fork}</a><br>upstream ${s.upstream}</td><td>${s.license}</td>`;
  tb.appendChild(tr);
}
$("copied").textContent = `${map.copied_files.length} source files copied unmodified (import closure) - see NOTICE.`;

entryPointStatus().then((s) => {
  $("live").innerHTML = s.deployed
    ? `<span class="ok">Deployed</span> at <span class="mono">${ENTRYPOINT_V09}</span> (${s.codeBytes} bytes), Sepolia block ${s.block}`
    : `<span class="warn">Not found</span>`;
}).catch((e) => ($("live").textContent = `RPC error: ${e.message}`));

($("addr") as HTMLInputElement).addEventListener("input", async (ev) => {
  const v = (ev.target as HTMLInputElement).value.trim();
  if (!isAddress(v)) { $("acct").textContent = ""; return; }
  const r = await accountStatus(v as Address);
  $("acct").textContent = `deposit ${r.deposit} ETH, nonce ${r.nonce}`;
});

$("deploy").addEventListener("click", async () => {
  const log = (m: string) => ($("deploylog").innerHTML += m + "<br>");
  const eth = (window as any).ethereum;
  if (!eth) return log("No injected wallet found.");
  const wallet = createWalletClient({ chain: sepolia, transport: custom(eth) });
  const [account] = await wallet.requestAddresses();
  await wallet.switchChain({ id: sepolia.id }).catch(() => {});
  const deploy = async (name: keyof typeof artifacts, args: unknown[]) => {
    const a = artifacts[name];
    const hash = await wallet.deployContract({ account, abi: a.abi as any, bytecode: a.bytecode as Hex, args: args as any });
    log(`${name} tx ${hash}`);
    const rc = await publicClient.waitForTransactionReceipt({ hash });
    log(`${name} deployed at ${rc.contractAddress}`);
    return rc.contractAddress as Address;
  };
  try {
    const factory = await deploy("SimpleAccountFactory", [ENTRYPOINT_V09]);
    const club = await deploy("MembershipNFT", [account, "ipfs://club/"]);
    const pm = await deploy("ClubPaymaster", [ENTRYPOINT_V09, club, parseEther("0.005"), account]);
    const hash = await wallet.writeContract({ account, address: pm, abi: artifacts.ClubPaymaster.abi as any, functionName: "deposit", value: parseEther("0.01") });
    await publicClient.waitForTransactionReceipt({ hash });
    log(`Paymaster funded. Factory ${factory}, club ${club}, paymaster ${pm}. Approve member accounts with MembershipNFT.setApproved().`);
  } catch (e: any) { log(`Error: ${e.shortMessage ?? e.message}`); }
});
