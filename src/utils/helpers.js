export function getNetworkName(id) {
  switch (id) {
    case 3:
      return "Ropsten";
    case 4:
      return "Rinkby";
    case 42:
      return "Kovan";
    default:
      return "localhost";
  }
}

export async function getAccountBalance(account, web3) {
  try {
    const balance = await web3.eth.getBalance(account);
    Promise.resolve(web3.utils.fromWei(balance, "ether"));
  } catch (error) {
    Promise.reject(error);
  }
}

export default {getNetworkName, getAccountBalance};
