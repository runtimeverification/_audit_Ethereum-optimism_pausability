import json
import sys
from pathlib import Path

class DeploymentSummary:
    SOLIDITY_VERSION = '0.8.15'

    name: str
    commands: list[str]
    accounts: dict[str, str] # address, name

    def __init__(self, name: str, accounts: dir) -> None:
        self.commands = []
        self.accounts = accounts
        self.name = name
        for acc_key in list(self.accounts):
            self.accounts[acc_key] = self.accounts[acc_key] + 'Address'

    def generate(self) -> str:
        lines = []
        lines.append(f'pragma solidity {self.SOLIDITY_VERSION};\n')
        lines.append('import "forge-std/Test.sol";\n')
        lines.append(f'contract {self.name} is Test ' + '{')

        for acc_key in list(self.accounts):
            lines.append('\taddress public ' + self.accounts[acc_key] + ';')

        lines.append('\n')

        lines.append('\tfunction recreateDeployment() public {')

        for acc_key in list(self.accounts):
            lines.append('\t\t' + self.accounts[acc_key] + ' = ' + acc_key + ';')
        
        lines.append('\n')
        
        lines.append('\t\tbytes memory code;')
        lines.append('\t\tbytes32 slot;')
        lines.append('\t\tbytes32 value;')

        for command in self.commands:
            lines.append('\t\t' + command + ';')

        lines.append('\t}')

        lines.append('}')
        return '\n'.join(lines)

    def add_cheatcode(self, dct: dict) -> None:
        kind             = dct['kind']
        account          = dct['account']
        accessor         = dct['accessor']
        initialized      = dct['initialized']
        old_balance      = dct['oldBalance']
        new_balance      = dct['newBalance']
        deployed_code    = dct['deployedCode']
        value            = dct['value']
        reverted         = dct['reverted']
        storage_accesses = dct['storageAccesses']

        # Add a dummy name to the account and store it
        if account not in list(self.accounts):
            acc_name = 'acc' + str(len(list(self.accounts)))
            self.accounts[account] = acc_name

        if reverted:
            return

        if deployed_code != '0x' and kind == 'Create':
            self.commands.append(f'code = hex{deployed_code[2:]!r}')
            self.commands.append(f'vm.etch({self.accounts[account]}, code)')

        if new_balance != old_balance:
            self.commands.append(f'vm.deal({self.accounts[account]}, {new_balance})')

        for storage_access in storage_accesses:
            account        = storage_access['account']
            slot           = storage_access['slot']
            is_write       = storage_access['isWrite']
            previous_value = storage_access['previousValue']
            new_value      = storage_access['newValue']
            reverted       = storage_access['reverted']

            if reverted or not is_write or new_value == previous_value:
                continue

            acc_name = self.accounts[account] if account in list(self.accounts) else account
            self.commands.append(f'slot = hex{slot[2:]!r}')
            self.commands.append(f'value = hex{new_value[2:]!r}')
            self.commands.append(f'vm.store({acc_name}, slot, value)')

def main(name: str, accesses_file: Path, contract_names: Path) -> None:
    accesses = json.loads(accesses_file.read_text())['accountAccesses']
    accounts = {}
    if contract_names.exists():
        accounts = json.loads(contract_names.read_text())
    summary_contract = DeploymentSummary(name=name, accounts=accounts)
    for access in accesses:
        summary_contract.add_cheatcode(access)

    print(summary_contract.generate())


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: python3 generate.py <name> <contract_names_file> <accesses_file>")
        sys.exit(1)

    name = sys.argv[1]
    contract_names_path = Path(sys.argv[2])
    accesses_path = Path(sys.argv[3])
    main(name, accesses_path, contract_names_path)
