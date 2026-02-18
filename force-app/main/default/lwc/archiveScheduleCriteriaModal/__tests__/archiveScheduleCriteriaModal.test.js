import { createElement } from '@lwc/engine-dom';
import ArchiveScheduleCriteriaModal from 'c/archiveScheduleCriteriaModal';
import getFieldsBySObject from '@salesforce/apex/sObjectsController.getFieldsBySObject';

// Mock Apex
jest.mock(
    '@salesforce/apex/sObjectsController.getFieldsBySObject',
    () => ({ default: jest.fn() }),
    { virtual: true }
);

describe('c-archive-schedule-criteria-modal', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders the modal with title', () => {
        const element = createElement('c-archive-schedule-criteria-modal', {
            is: ArchiveScheduleCriteriaModal
        });
        element.selectedObject = 'Account';
        document.body.appendChild(element);

        const title = element.shadowRoot.querySelector('h2');
        expect(title.textContent.trim()).toBe('Define Schedule Criteria');
    });

    it('dispatches close event on close button click', () => {
        const element = createElement('c-archive-schedule-criteria-modal', {
            is: ArchiveScheduleCriteriaModal
        });
        element.selectedObject = 'Account';
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('close', handler);

        const closeBtn = element.shadowRoot.querySelector('button[title="Close"]');
        closeBtn.click();

        expect(handler).toHaveBeenCalled();
    });

    it('shows loading spinner initially', () => {
        const element = createElement('c-archive-schedule-criteria-modal', {
            is: ArchiveScheduleCriteriaModal
        });
        element.selectedObject = 'Account';
        document.body.appendChild(element);

        const spinner = element.shadowRoot.querySelector('lightning-spinner');
        expect(spinner).not.toBeNull();
    });
});