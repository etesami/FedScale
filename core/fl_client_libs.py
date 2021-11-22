# package for client
from fllibs import *
from torch.nn.utils.rnn import pad_sequence
import os

logDir = os.path.join(args.log_path, "logs", args.job_name, args.time_stamp, 'executor')
logFile = os.path.join(logDir, 'log')

YELLOW_BOLD = "\033[1;93m"
CYAN_BOLD = "\033[1;36m"
RESET = "\033[0m"

class CustomFormatter(logging.Formatter):
    
    grey = "\033[1;37m"
    light_blue = "\033[34m"
    bold_yellow = "\033[1;93m"
    yellow = "\033[93m"
    red = "\033[91m"
    bold_red = "\033[1;91m"
    reset = "\033[0m"
    format = '%(asctime)s [%(levelname)-5s] %(message)s (%(filename)s:%(lineno)d)'

    FORMATS = {
        logging.DEBUG: light_blue + format + reset,
        logging.INFO: grey + format + reset,
        logging.WARNING: bold_yellow + format + reset,
        logging.ERROR: red + format + reset,
        logging.CRITICAL: bold_red + format + reset
    }

    def format(self, record):
        log_fmt = self.FORMATS.get(record.levelno)
        formatter = logging.Formatter(fmt=log_fmt, datefmt='[%m-%d] %H:%M:%S')
        return formatter.format(record)

def init_logging():
    if not os.path.isdir(logDir):
        os.makedirs(logDir, exist_ok=True)
        
    sh = logging.StreamHandler()
    sh.setFormatter(CustomFormatter())
    fh = logging.FileHandler(logFile, mode='a')
    fh.setFormatter(CustomFormatter())
    logging.basicConfig(
                    level=logging.INFO,
                    handlers=[fh, sh])

def get_ps_ip():
    global args

    ip_file = os.path.join(logDir, '../aggregator/ip')
    ps_ip = None
    while not os.path.exists(ip_file):
        time.sleep(1)

    with open(ip_file, 'rb') as fin:
        ps_ip = pickle.load(fin)

    args.ps_ip = ps_ip
    logging.info('[L] Config ps_ip on {}, args.ps_ip is {}'.format(ps_ip, args.ps_ip))


def initiate_client_setting():
    init_logging()


def collate(examples):
    if tokenizer._pad_token is None:
        return (pad_sequence(examples, batch_first=True), None)
    return (pad_sequence(examples, batch_first=True, padding_value=tokenizer.pad_token_id), None)

def voice_collate_fn(batch):
    def func(p):
        return p[0].size(1)

    start_time = time.time()

    batch = sorted(batch, key=lambda sample: sample[0].size(1), reverse=True)
    longest_sample = max(batch, key=func)[0]
    freq_size = longest_sample.size(0)
    minibatch_size = len(batch)
    max_seqlength = longest_sample.size(1)
    inputs = torch.zeros(minibatch_size, 1, freq_size, max_seqlength)
    input_percentages = torch.FloatTensor(minibatch_size)
    target_sizes = torch.IntTensor(minibatch_size)
    targets = []
    for x in range(minibatch_size):
        sample = batch[x]
        tensor = sample[0]
        target = sample[1]
        seq_length = tensor.size(1)
        inputs[x][0].narrow(1, 0, seq_length).copy_(tensor)
        input_percentages[x] = seq_length / float(max_seqlength)
        target_sizes[x] = len(target)
        targets.extend(target)
    targets = torch.IntTensor(targets)

    end_time = time.time()

    return (inputs, targets, input_percentages, target_sizes), None

# initiate the log path, and executor ips
initiate_client_setting()

